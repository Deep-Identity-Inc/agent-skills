# deepidv Sessions and Workflows Error Guide

This guide is limited to the HTTP error conditions published on the docs pages for session and workflow endpoints.

## Scope

Covered endpoints:

- `POST /v1/sessions`
- `GET /v1/sessions`
- `GET /v1/sessions/{id}`
- `PATCH /v1/sessions/{id}/update-status`
- `POST /v1/workflows`
- `GET /v1/workflows`
- `GET /v1/workflows/{id}`

The docs pages do not currently publish application-specific error codes for these endpoints. Avoid inventing internal codes in client logic. Use the HTTP status plus the endpoint context instead.

## HTTP Failure Classes

| Status | Class            | Meaning                                                           | Operator Action                         |
| ------ | ---------------- | ----------------------------------------------------------------- | --------------------------------------- |
| `400`  | Validation       | Request parameters, path values, or body fields are invalid       | Correct the request before retrying     |
| `401`  | Authentication   | API key is missing or invalid                                     | Fix credentials before retrying         |
| `402`  | Balance          | The account has insufficient token balance for session creation   | Replenish balance before retrying       |
| `403`  | Authorization    | The key cannot perform the requested operation or resource access | Use the correct organization context    |
| `404`  | Missing Resource | The supplied workflow or session ID does not exist                | Re-check the identifier before retrying |
| `429`  | Rate Limit       | Too many requests were sent                                       | Back off and retry conservatively       |

## Endpoint-Specific Guidance

### Create Session

`POST /v1/sessions`

| Status | Likely Cause                                                                       | Operator Action                                              |
| ------ | ---------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| `400`  | Missing required applicant fields, invalid phone format, or malformed request body | Supply `first_name`, `last_name`, `email`, and E.164 `phone` |
| `401`  | API key missing or invalid                                                         | Fix `x-api-key`                                              |
| `402`  | Insufficient token balance                                                         | Add balance before retrying                                  |
| `404`  | Provided `workflow_id` does not exist                                              | Retrieve workflows first and retry with a valid ID           |
| `429`  | Burst or account throttling                                                        | Retry later                                                  |

### List Sessions

`GET /v1/sessions`

| Status | Likely Cause                                                   | Operator Action                 |
| ------ | -------------------------------------------------------------- | ------------------------------- |
| `400`  | `limit` out of range, invalid dates, or malformed `next_token` | Correct the query parameters    |
| `401`  | API key missing or invalid                                     | Fix `x-api-key`                 |
| `429`  | Request rate too high                                          | Slow pagination and retry later |

### Retrieve Session

`GET /v1/sessions/{id}`

| Status | Likely Cause                            | Operator Action                       |
| ------ | --------------------------------------- | ------------------------------------- |
| `400`  | Invalid session ID format               | Validate the ID before retrying       |
| `401`  | API key missing or invalid              | Fix `x-api-key`                       |
| `403`  | Session belongs to another organization | Use a key for the owning organization |
| `404`  | Session ID not found                    | Confirm the session exists            |
| `429`  | Request rate too high                   | Back off and retry later              |

### Update Session Status

`PATCH /v1/sessions/{id}/update-status`

| Status | Likely Cause                                   | Operator Action                       |
| ------ | ---------------------------------------------- | ------------------------------------- |
| `400`  | Invalid session ID or unsupported `new_status` | Use `VERIFIED` or `REJECTED` only     |
| `401`  | API key missing or invalid                     | Fix `x-api-key`                       |
| `403`  | Session belongs to another organization        | Use a key for the owning organization |
| `404`  | Session ID not found                           | Confirm the session exists            |
| `429`  | Request rate too high                          | Retry later                           |

### Create Workflow

`POST /v1/workflows`

| Status | Likely Cause                                                              | Operator Action                         |
| ------ | ------------------------------------------------------------------------- | --------------------------------------- |
| `400`  | Missing workflow name, invalid step ID, invalid config, or duplicate step | Correct the request body and retry      |
| `401`  | API key missing or invalid                                                | Fix `x-api-key`                         |
| `403`  | Sandbox API key used for workflow creation                                | Retry with a production-capable API key |
| `429`  | Request rate too high                                                     | Retry later                             |

### List Workflows

`GET /v1/workflows`

| Status | Likely Cause               | Operator Action |
| ------ | -------------------------- | --------------- |
| `401`  | API key missing or invalid | Fix `x-api-key` |
| `429`  | Request rate too high      | Retry later     |

### Retrieve Workflow

`GET /v1/workflows/{id}`

| Status | Likely Cause                             | Operator Action                       |
| ------ | ---------------------------------------- | ------------------------------------- |
| `401`  | API key missing or invalid               | Fix `x-api-key`                       |
| `403`  | Workflow belongs to another organization | Use a key for the owning organization |
| `404`  | Workflow ID not found on retrieve        | Re-check the workflow ID              |
| `429`  | Request rate too high                    | Retry later                           |

## Recovery Guidance

- Do not blindly retry `400`, `401`, `402`, `403`, or `404` responses.
- Retry `429` only after reducing request frequency.
- Prefer `GET /v1/workflows` before session creation when a workflow ID may be stale or unknown.
- Use `POST /v1/workflows` only with a production-capable key because sandbox keys are rejected.
- Prefer `GET /v1/sessions?external_id=...` when you have a caller reference and need to recover a lost session ID.
