# deepidv Sessions, Workflows, and Screening Error Guide

This guide is limited to the HTTP failures and typed outcome variants published
for the deepidv session, workflow, screening, and async-job endpoints used by
this skill.

## Covered Endpoints

- `POST /v1/sessions`
- `GET /v1/sessions`
- `GET /v1/sessions/{id}`
- `PATCH /v1/sessions/{id}/update-status`
- `POST /v1/workflows`
- `GET /v1/workflows`
- `GET /v1/workflows/{id}`
- `POST /v1/screening/pep-sanctions`
- `POST /v1/screening/title-check`
- `POST /v1/screening/adverse-media`
- `GET /v1/async-jobs/{jobId}`

The published docs do not expose a separate catalog of internal application
error codes for these endpoints. Use the HTTP status together with the endpoint
context instead of inventing private codes in client logic.

## HTTP Failure Classes

| Status | Class | Meaning | Operator Action |
| ------ | ----- | ------- | --------------- |
| `400` | Validation | Request parameters, path values, or body fields are invalid | Correct the request before retrying |
| `401` | Authentication | API key is missing or invalid | Fix credentials before retrying |
| `402` | Balance | The account has insufficient token balance for session creation | Replenish balance before retrying |
| `403` | Authorization | The key cannot perform the requested operation or access the resource | Use the correct organization context or a production-capable key |
| `404` | Missing Resource | The supplied workflow, session, or job ID does not exist | Re-check the identifier before retrying |
| `429` | Rate Limit | Too many requests were sent | Back off and retry conservatively |
| `503` | Upstream Screening Failure | The screening provider could not complete the request | Retry cautiously or escalate to operations |

## Endpoint-Specific Guidance

### Create Session

`POST /v1/sessions`

| Status | Likely Cause | Operator Action |
| ------ | ------------ | --------------- |
| `400` | Missing applicant fields, invalid phone format, or malformed body | Supply `first_name`, `last_name`, `email`, and E.164 `phone` |
| `401` | API key missing or invalid | Fix `x-api-key` |
| `402` | Insufficient token balance | Add balance before retrying |
| `404` | Provided `workflow_id` does not exist | Retrieve workflows first and retry with a valid ID |
| `429` | Burst or account throttling | Retry later |

### List Sessions

`GET /v1/sessions`

| Status | Likely Cause | Operator Action |
| ------ | ------------ | --------------- |
| `400` | `limit` out of range, invalid dates, or malformed `next_token` | Correct the query parameters |
| `401` | API key missing or invalid | Fix `x-api-key` |
| `429` | Request rate too high | Slow pagination and retry later |

### Retrieve Session

`GET /v1/sessions/{id}`

| Status | Likely Cause | Operator Action |
| ------ | ------------ | --------------- |
| `400` | Invalid session ID format | Validate the ID before retrying |
| `401` | API key missing or invalid | Fix `x-api-key` |
| `403` | Session belongs to another organization | Use a key for the owning organization |
| `404` | Session ID not found | Confirm the session exists |
| `429` | Request rate too high | Back off and retry later |

### Update Session Status

`PATCH /v1/sessions/{id}/update-status`

| Status | Likely Cause | Operator Action |
| ------ | ------------ | --------------- |
| `400` | Invalid session ID or unsupported `new_status` | Use `VERIFIED` or `REJECTED` only |
| `401` | API key missing or invalid | Fix `x-api-key` |
| `403` | Session belongs to another organization | Use a key for the owning organization |
| `404` | Session ID not found | Confirm the session exists |
| `429` | Request rate too high | Retry later |

### Create Workflow

`POST /v1/workflows`

| Status | Likely Cause | Operator Action |
| ------ | ------------ | --------------- |
| `400` | Missing workflow name, invalid step ID, invalid config, or duplicate step | Correct the request body and retry |
| `401` | API key missing or invalid | Fix `x-api-key` |
| `403` | Sandbox API key used for workflow creation | Retry with a production-capable API key |
| `429` | Request rate too high | Retry later |

### List Workflows

`GET /v1/workflows`

| Status | Likely Cause | Operator Action |
| ------ | ------------ | --------------- |
| `401` | API key missing or invalid | Fix `x-api-key` |
| `429` | Request rate too high | Retry later |

### Retrieve Workflow

`GET /v1/workflows/{id}`

| Status | Likely Cause | Operator Action |
| ------ | ------------ | --------------- |
| `401` | API key missing or invalid | Fix `x-api-key` |
| `403` | Workflow belongs to another organization | Use a key for the owning organization |
| `404` | Workflow ID not found | Re-check the workflow ID |
| `429` | Request rate too high | Retry later |

### Run PEP and Sanctions

`POST /v1/screening/pep-sanctions`

| Status | Likely Cause | Operator Action |
| ------ | ------------ | --------------- |
| `400` | Missing subject fields or malformed date | Correct the body and retry |
| `401` | API key missing or invalid | Fix `x-api-key` |
| `429` | Request rate too high | Retry later |
| `503` | Screening provider temporarily unavailable | Retry cautiously or escalate |

### Run Title Check

`POST /v1/screening/title-check`

| Status | Likely Cause | Operator Action |
| ------ | ------------ | --------------- |
| `400` | Missing subject fields or malformed address input | Correct the body and retry |
| `401` | API key missing or invalid | Fix `x-api-key` |
| `429` | Request rate too high | Retry later |
| `503` | Title-search provider temporarily unavailable | Retry cautiously or escalate |

Important: several title-check outcomes are not errors. Branch on the returned
`status` instead of converting them into failures:

- `found`
- `multiple_properties`
- `unsupported_region`
- `not_found`

### Queue Adverse Media

`POST /v1/screening/adverse-media`

| Status | Likely Cause | Operator Action |
| ------ | ------------ | --------------- |
| `400` | Missing subject fields or malformed request body | Correct the body and retry |
| `401` | API key missing or invalid | Fix `x-api-key` |
| `429` | Request rate too high | Retry later |

Important:

- The first successful response is a job acknowledgement, not the final
  screening result.
- Reusing an `Idempotency-Key` may return the existing job instead of queuing a
  new screening.

### Get Async Job

`GET /v1/async-jobs/{jobId}`

Use the returned `status` as the primary control flow, not just the HTTP code.

- `pending` and `processing` mean keep polling.
- `ready` means read `result`.
- `failed` means read `error` and decide whether to retry the original
  screening.

If the request fails at the HTTP level, expect the same broad classes used
elsewhere: validation, authentication, missing resource, or throttling.

## Recovery Guidance

- Do not blindly retry `400`, `401`, `402`, `403`, or `404` responses.
- Retry `429` only after reducing request frequency.
- Retry `503` cautiously because the failure is upstream and may outlast the
  current request window.
- Prefer `GET /v1/workflows` before session creation when a workflow ID may be
  stale or unknown.
- Use `POST /v1/workflows` only with a production-capable key because sandbox
  keys are rejected.
- Prefer `GET /v1/sessions?external_id=...` when you have a caller reference
  and need to recover a lost session ID.
- For async adverse-media flows, retry the original screening only after
  checking whether an existing `jobId` can still be recovered or resumed.
