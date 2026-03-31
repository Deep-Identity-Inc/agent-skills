# deepidv Sessions and Workflows API Reference

This document summarizes the session and workflow endpoints currently published on the deepidv docs site.

## Base URL

Use a single base URL for both sandbox and production traffic:

- `https://api.deepidv.com/v1`

The API key determines whether the request is processed in sandbox or production mode.

## Authentication

All requests require the `x-api-key` header.

Credential sources, in priority order:

1. `DEEPIDV_API_KEY`
2. `.deepidv/credentials` in the current project
3. `.deepidv/credentials` in the user home directory

Supported credential file formats:

```text
DEEPIDV_API_KEY=sk_test_example
```

or:

```text
sk_test_example
```

## Common Headers

| Header         | Required                   | Description                |
| -------------- | -------------------------- | -------------------------- |
| `x-api-key`    | Yes                        | deepidv API key            |
| `Content-Type` | Yes for `POST` and `PATCH` | Must be `application/json` |

## Sessions

### 1. Create Session

`POST /v1/sessions`

Creates a new identity verification session and can optionally send email and SMS invitations.

Body parameters:

| Snake Case          | Camel Case        | Type    | Required | Description                                       |
| ------------------- | ----------------- | ------- | -------- | ------------------------------------------------- |
| `first_name`        | `firstName`       | string  | Yes      | Applicant first name                              |
| `last_name`         | `lastName`        | string  | Yes      | Applicant last name                               |
| `email`             | —                 | string  | Yes      | Applicant email address                           |
| `phone`             | —                 | string  | Yes      | Applicant phone number in E.164 format            |
| `external_id`       | `externalId`      | string  | No       | Caller reference for the session                  |
| `send_email_invite` | `sendEmailInvite` | boolean | No       | Send an email invite, defaults to `true`          |
| `send_phone_invite` | `sendPhoneInvite` | boolean | No       | Send an SMS invite, defaults to `true`            |
| `workflow_id`       | `workflowId`      | string  | No       | Workflow to run. Omit for standalone verification |
| `redirect_url`      | `redirectUrl`     | string  | No       | HTTPS return URL after the session ends           |

Request notes:

- Both camelCase and snake_case are accepted.
- If both are provided for the same field, the camelCase value takes priority.

Example request:

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "phone": "+15192223333",
  "external_id": "user-12345",
  "workflow_id": "wf_abc123",
  "redirect_url": "https://yourapp.com/verify-callback"
}
```

Success response:

```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "session_url": "https://app.deepidv.com",
  "externalId": "user-12345",
  "links": []
}
```

Response fields:

| Field         | Type   | Meaning                                  |
| ------------- | ------ | ---------------------------------------- |
| `id`          | string | Unique session identifier                |
| `session_url` | string | Applicant-facing verification URL        |
| `externalId`  | string | Caller reference, returned when provided |
| `links`       | array  | Associated verification links            |

Redirect URL behavior:

- When `redirect_url` is provided, the returned `session_url` includes it as an encoded query parameter.
- deepidv redirects the user back with `session_id`, `status`, and optional `reason`.

Redirect status values:

- `success`
- `failed`
- `abandoned`

Published redirect reason values:

- `document_unreadable`
- `face_mismatch`
- `session_expired`
- `internal_error`
- `user_cancelled`
- `unknown`

Error responses:

| Status | Meaning                                                       |
| ------ | ------------------------------------------------------------- |
| `400`  | Invalid request body, missing fields, or invalid phone format |
| `401`  | Missing or invalid API key                                    |
| `402`  | Insufficient token balance                                    |
| `404`  | Workflow ID not found                                         |
| `429`  | Rate limit exceeded                                           |

### 2. List Sessions

`GET /v1/sessions`

Returns a paginated list of verification sessions.

Query parameters:

| Field             | Type    | Required | Default | Description                                                                  |
| ----------------- | ------- | -------- | ------- | ---------------------------------------------------------------------------- |
| `limit`           | number  | No       | `50`    | Number of sessions to return, from `1` to `500`                              |
| `next_token`      | string  | No       | —       | Pagination token from a previous response                                    |
| `start_date`      | string  | No       | —       | Sessions created on or after this ISO 8601 timestamp                         |
| `end_date`        | string  | No       | —       | Sessions created on or before this ISO 8601 timestamp                        |
| `by_organization` | boolean | No       | `false` | Return all organization sessions instead of only those created by the caller |
| `external_id`     | string  | No       | —       | Filter by caller reference ID                                                |
| `workflow_id`     | string  | No       | —       | Filter by workflow ID                                                        |

Query evaluation priority:

1. `external_id`
2. `workflow_id`
3. `by_organization`
4. default sender-based query

Example response:

```json
{
  "sessions": [
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "organization_id": "org_abc123",
      "user_id": "usr_def456",
      "sender_user_id": "usr_ghi789",
      "status": "VERIFIED",
      "type": "session",
      "session_progress": "COMPLETED",
      "created_at": "2025-01-15T10:30:00.000Z",
      "updated_at": "2025-01-15T10:45:00.000Z"
    }
  ],
  "next_token": "eyJpZCI6ImFiYzEyMyJ9"
}
```

Response fields:

| Field        | Type           | Meaning                                          |
| ------------ | -------------- | ------------------------------------------------ |
| `sessions`   | array          | Session objects using the `session_record` shape |
| `next_token` | string or null | Pagination token for the next page               |

Notes:

- List responses do not include `user`, `sender_user`, or `resource_links`.
- Continue paginating until `next_token` is `null`.

Error responses:

| Status | Meaning                                                       |
| ------ | ------------------------------------------------------------- |
| `400`  | Invalid query parameters, date format, limit, or `next_token` |
| `401`  | Missing or invalid API key                                    |
| `429`  | Rate limit exceeded                                           |

### 3. Retrieve Session

`GET /v1/sessions/{id}`

Retrieves the full details of a single verification session by its session ID, including analysis results and presigned URLs for uploaded documents.

Path parameters:

| Field | Type   | Required | Description                               |
| ----- | ------ | -------- | ----------------------------------------- |
| `id`  | string | Yes      | Session ID returned from session creation |

Top-level response fields:

| Field            | Type   | Meaning                                     |
| ---------------- | ------ | ------------------------------------------- |
| `session_record` | object | Full session object                         |
| `resource_links` | object | Presigned URLs for uploaded files           |
| `user`           | object | Applicant profile when available            |
| `sender_user`    | object | User who created the session when available |

Important `session_record` fields:

| Field              | Type     | Meaning                                                                            |
| ------------------ | -------- | ---------------------------------------------------------------------------------- |
| `id`               | string   | Unique session identifier                                                          |
| `organization_id`  | string   | Owning organization                                                                |
| `user_id`          | string   | Applicant user ID                                                                  |
| `sender_user_id`   | string   | Creator user ID                                                                    |
| `external_id`      | string   | Caller reference ID                                                                |
| `status`           | string   | `PENDING`, `SUBMITTED`, `VERIFIED`, `REJECTED`, or `VOIDED`                        |
| `type`             | string   | `session`, `verification`, `credit-application`, `silent-screening`, or `deep-doc` |
| `session_progress` | string   | `PENDING`, `STARTED`, or `COMPLETED`                                               |
| `created_at`       | string   | Session creation timestamp                                                         |
| `updated_at`       | string   | Last update timestamp                                                              |
| `submitted_at`     | string   | Applicant submission timestamp                                                     |
| `workflow_id`      | string   | Workflow used by the session                                                       |
| `workflow_steps`   | string[] | Workflow step IDs                                                                  |
| `uploads`          | object   | Booleans describing which uploads are present                                      |
| `analysis_data`    | object   | Verification and screening analysis results                                        |
| `meta_data`        | object   | Applicant submission metadata                                                      |

Key `analysis_data` fields called out by the docs:

- `id_analysis_data`
- `id_matches_selfie`
- `faceliveness_score`
- `compare_faces_data`
- `pep_sanctions_data`
- `adverse_media_data`
- `secondary_id_analysis_data`
- `tertiary_id_analysis_data`
- `selected_document_types`
- `document_risk_data`
- `title_search_data`
- `custom_form_data`

Error responses:

| Status | Meaning                                     |
| ------ | ------------------------------------------- |
| `400`  | Invalid session ID format                   |
| `401`  | Missing or invalid API key                  |
| `403`  | Session belongs to a different organization |
| `404`  | Session ID does not exist                   |
| `429`  | Rate limit exceeded                         |

### 4. Update Session Status

`PATCH /v1/sessions/{id}/update-status`

Manually updates a session to `VERIFIED` or `REJECTED`.

Path parameters:

| Field | Type   | Required | Description                               |
| ----- | ------ | -------- | ----------------------------------------- |
| `id`  | string | Yes      | Session ID returned from session creation |

Body parameters:

| Field        | Type   | Required | Description                      |
| ------------ | ------ | -------- | -------------------------------- |
| `new_status` | string | Yes      | Must be `VERIFIED` or `REJECTED` |

Example request:

```json
{
  "new_status": "VERIFIED"
}
```

Success response fields:

| Field            | Type   | Meaning                |
| ---------------- | ------ | ---------------------- |
| `session_record` | object | Updated session object |

Error responses:

| Status | Meaning                                     |
| ------ | ------------------------------------------- |
| `400`  | Invalid session ID or invalid `new_status`  |
| `401`  | Missing or invalid API key                  |
| `403`  | Session belongs to a different organization |
| `404`  | Session ID does not exist                   |
| `429`  | Rate limit exceeded                         |

## Workflows

### 5. List Workflows

`GET /v1/workflows`

Returns all workflows for the organization, sorted by creation date with the newest first.

Success response:

```json
{
  "workflows": [
    {
      "id": "6d6da499-9225-40fb-9ffd-a06634b915bd",
      "name": "Full Verification",
      "created_at": "2026-03-01T17:30:24.573Z"
    },
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "name": "Basic ID Check",
      "created_at": "2026-02-15T09:30:00.000Z"
    }
  ]
}
```

Response fields:

| Field                    | Type   | Meaning                  |
| ------------------------ | ------ | ------------------------ |
| `workflows`              | array  | Workflow summary objects |
| `workflows[].id`         | string | Workflow identifier      |
| `workflows[].name`       | string | Workflow name            |
| `workflows[].created_at` | string | Creation timestamp       |

Error responses:

| Status | Meaning                    |
| ------ | -------------------------- |
| `401`  | Missing or invalid API key |
| `429`  | Rate limit exceeded        |

### 6. Retrieve Workflow

`GET /v1/workflows/{id}`

Returns the full workflow record for the given ID.

Path parameters:

| Field | Type   | Required | Description |
| ----- | ------ | -------- | ----------- |
| `id`  | string | Yes      | Workflow ID |

Response fields:

| Field                      | Type   | Meaning                            |
| -------------------------- | ------ | ---------------------------------- |
| `workflow`                 | object | Workflow record                    |
| `workflow.id`              | string | Workflow identifier                |
| `workflow.name`            | string | Workflow name                      |
| `workflow.organization_id` | string | Owning organization                |
| `workflow.status`          | string | `active` or `inactive`             |
| `workflow.created_at`      | string | Creation timestamp                 |
| `workflow.updated_at`      | string | Last update timestamp              |
| `workflow.steps`           | array  | Ordered list of verification steps |
| `workflow.steps[].id`      | string | Step identifier                    |
| `workflow.steps[].config`  | object | Step configuration                 |

Example step IDs shown on the docs site:

- `id-verification`
- `face-liveness`
- `age-estimation`
- `pep-sanctions`
- `adverse-media`
- `bank-statement-upload`
- `document-upload`
- `title-search`
- `custom-prompt`
- `custom-form`
- `ai-bank-statement-analysis`

Operational note from the docs:

- To list sessions for a workflow, call `GET /v1/sessions` with `workflow_id`.

Error responses:

| Status | Meaning                                      |
| ------ | -------------------------------------------- |
| `401`  | Missing or invalid API key                   |
| `403`  | Workflow belongs to a different organization |
| `404`  | No workflow found with the given ID          |
| `429`  | Rate limit exceeded                          |
