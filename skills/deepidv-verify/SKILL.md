---
name: deepidv-verify
description: >-
  Identity verification, KYC, face liveness, deepfake detection,
  adverse media screening, and AML/sanctions checks via the deepidv API.
  Use when a user needs to verify someone's identity, check if media is
  AI-generated, screen for sanctions/PEP status, or run adverse media checks.
license: Apache-2.0
compatibility:
  - claude-code
  - codex
  - cursor
  - opencode
  - windsurf
metadata:
  author: deepidv
  version: 1.0.0
  website: https://deepidv.com
  category: compliance
  tags:
    - kyc
    - identity
    - verification
    - liveness
    - deepfake
    - aml
    - sanctions
---

# deepidv Verify Skill

Use this skill when an agent needs to verify a person, validate identity media, or run compliance screening through the public deepidv Verify API.

## Capabilities Overview

Available capabilities:

- Face liveness
- Identity verification
- Deepfake detection
- Adverse media screening
- AML and sanctions screening
- Combined verification

Agents can discover this skill directly from this repository.

## Invocation Guidance

Choose the endpoint that matches the user intent directly:

| User Intent                                                               | Endpoint                                |
| ------------------------------------------------------------------------- | --------------------------------------- |
| Start a new applicant verification flow                                   | `POST /v1/sessions`                     |
| Find existing sessions by creator, organization, workflow, or external ID | `GET /v1/sessions`                      |
| Inspect the full outcome of one verification session                      | `GET /v1/sessions/{id}`                 |
| Manually resolve a session as approved or rejected                        | `PATCH /v1/sessions/{id}/update-status` |
| Discover which workflows are available before creating a session          | `GET /v1/workflows`                     |
| Inspect the exact steps configured in one workflow                        | `GET /v1/workflows/{id}`                |

Do not ask the user to choose an endpoint if the request already implies the right operation.

## Authentication

All requests require API-key authentication with the `x-api-key` header.

Credential lookup order:

1. `DEEPIDV_API_KEY` environment variable.
2. `.deepidv/credentials` under the current project root.
3. `.deepidv/credentials` under the user home directory.

The credential file may contain either a raw key or a line in `KEY=value` format, for example:

```text
DEEPIDV_API_KEY=sk_test_example
```

Request header:

```http
x-api-key: <api_key>
```

Never commit keys to the repository. Use sandbox keys for testing and live keys for production traffic.

## Base URL

Use a single base URL for all session and workflow traffic:

- `https://api.deepidv.com/v1`

The API key determines whether the request is handled as sandbox or production traffic.

## Sandbox Mode

Use sandbox for testing request construction, workflow selection, and redirect handling without sending production traffic.

- Use sandbox keys against `https://api.deepidv.com/v1`.
- Use non-production applicant data when validating session flows.
- Confirm pagination, workflow selection, and redirect handling in sandbox before enabling production traffic.

## Endpoint Reference

### Common Request Pattern

Create and update endpoints accept JSON request bodies.

```http
POST {base_url}/sessions
PATCH {base_url}/sessions/{id}/update-status
Content-Type: application/json
x-api-key: <api_key>
```

List and retrieve endpoints require the `x-api-key` header and do not require a request body.

### Endpoint Summary

| Operation             | Endpoint                                | Use When                                                       | Required Inputs                             | High-Value Response Fields                                |
| --------------------- | --------------------------------------- | -------------------------------------------------------------- | ------------------------------------------- | --------------------------------------------------------- |
| Create Session        | `POST /v1/sessions`                     | You need to start a verification flow for an applicant         | `first_name`, `last_name`, `email`, `phone` | `id`, `session_url`, `externalId`, `links`                |
| List Sessions         | `GET /v1/sessions`                      | You need to find prior sessions or paginate operational queues | none                                        | `sessions`, `next_token`                                  |
| Retrieve Session      | `GET /v1/sessions/{id}`                 | You need detailed status, uploads, or analysis results         | path `id`                                   | `session_record`, `resource_links`, `user`, `sender_user` |
| Update Session Status | `PATCH /v1/sessions/{id}/update-status` | Manual review has reached a final decision                     | path `id`, body `new_status`                | `session_record.status`, `session_record.updated_at`      |
| List Workflows        | `GET /v1/workflows`                     | You need to discover available workflow IDs                    | none                                        | `workflows[].id`, `workflows[].name`                      |
| Retrieve Workflow     | `GET /v1/workflows/{id}`                | You need exact workflow steps and configuration                | path `id`                                   | `workflow.steps`, `workflow.status`                       |

### Create Session

`POST /v1/sessions`

Use when a workflow must be launched for a specific applicant.

Important request notes:

- Both camelCase and snake_case body fields are accepted.
- If both are provided for the same field, the camelCase value wins.
- `workflow_id` is optional. If omitted, the session runs as a standalone verification.
- `redirect_url` must be a valid HTTPS URL.

Representative request:

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

High-level response meaning:

- `id` is the session identifier used by all follow-up session endpoints.
- `session_url` is the applicant-facing URL for completing verification.
- `links` contains any associated verification links returned by the API.

Redirect handling:

- When `redirect_url` is present, the verification app sends the user back with `session_id`, `status`, and optional `reason` query parameters.
- Published redirect `status` values are `success`, `failed`, and `abandoned`.
- Published `reason` values include `document_unreadable`, `face_mismatch`, `session_expired`, `internal_error`, `user_cancelled`, and `unknown`.

### List Sessions

`GET /v1/sessions`

Use when an operator or integration needs to search for existing sessions.

Supported query parameters:

- `limit` from `1` to `500`.
- `next_token` for pagination.
- `start_date` and `end_date` in ISO 8601 format.
- `by_organization=true` to query organization-wide sessions.
- `external_id` to find a session from the caller's reference ID.
- `workflow_id` to scope results to one workflow.

Filtering priority from the docs:

1. `external_id`
2. `workflow_id`
3. `by_organization`
4. default sender-based query

High-level response meaning:

- `sessions` is a paginated list of session objects.
- `next_token` is `null` when no additional page is available.

### Retrieve Session

`GET /v1/sessions/{id}`

Use when you need the full verification outcome for one session.

Important fields in `session_record`:

- `status`: `PENDING`, `SUBMITTED`, `VERIFIED`, `REJECTED`, or `VOIDED`.
- `type`: `session`, `verification`, `credit-application`, `silent-screening`, or `deep-doc`.
- `session_progress`: `PENDING`, `STARTED`, or `COMPLETED`.
- `workflow_id` and `workflow_steps` to correlate the run to its configured flow.
- `uploads` to confirm which artifacts were submitted.
- `analysis_data` for liveness, document, face match, sanctions, adverse media, and related results.

Top-level response fields:

- `session_record`
- `resource_links`
- `user`
- `sender_user`

### Update Session Status

`PATCH /v1/sessions/{id}/update-status`

Use when a manual or downstream review process must finalize a session.

Representative request:

```json
{
  "new_status": "VERIFIED"
}
```

Rules from the docs:

- `new_status` must be `VERIFIED` or `REJECTED`.
- The response returns the updated `session_record` only.

### List Workflows

`GET /v1/workflows`

Use when you need to discover workflow IDs before creating sessions.

High-level response meaning:

- `workflows` is an array of workflow summaries.
- Each summary includes `id`, `name`, and `created_at`.
- Results are sorted by creation date, newest first.

### Retrieve Workflow

`GET /v1/workflows/{id}`

Use when you need the workflow configuration behind a session or before creating one.

High-level response meaning:

- `workflow.status` is `active` or `inactive`.
- `workflow.steps` is the ordered verification sequence.
- Each step has an `id` and a `config` object.

Representative step IDs shown in the docs include:

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

## Workflows

### Session Creation From Workflow

1. Use `GET /v1/workflows` when the caller does not already know the workflow ID.
2. Use `GET /v1/workflows/{id}` when step-level configuration must be reviewed before launch.
3. Use `POST /v1/sessions` with `workflow_id` to create the applicant session.

### Session Operations

1. Use `GET /v1/sessions` to find the right session by external ID, workflow ID, creator, or organization scope.
2. Use `GET /v1/sessions/{id}` to inspect the outcome, uploads, and analysis results.
3. Use `PATCH /v1/sessions/{id}/update-status` only when a final manual decision must override or complete the session lifecycle.

### Redirect-Based Integrations

1. Supply `redirect_url` on session creation when the user must return to an application flow after verification.
2. Parse `session_id`, `status`, and optional `reason` from the redirect query string.
3. Reconcile redirect outcomes against `GET /v1/sessions/{id}` if the integration needs authoritative analysis data.

## Error Handling

Use the HTTP status code together with the endpoint-specific validation rules from the docs.

| HTTP Status | Meaning                                                 | Action                                                         |
| ----------- | ------------------------------------------------------- | -------------------------------------------------------------- |
| `400`       | Invalid request parameters, body fields, or path format | Correct the request before retrying                            |
| `401`       | Missing or invalid API key                              | Refresh credentials and retry only after fixing authentication |
| `402`       | Insufficient token balance on session creation          | Replenish balance before retrying                              |
| `403`       | Session or workflow belongs to a different organization | Use the correct organization context                           |
| `404`       | Session or workflow ID not found                        | Re-check the supplied identifier                               |
| `429`       | Rate limit exceeded                                     | Wait and retry conservatively                                  |

Use the detailed error catalog for operation-specific recovery guidance:

- `references/error-codes.md`

## Rate Limits

The docs site exposes `429 Too Many Requests` for session and workflow endpoints but does not publish fixed numeric quotas in these pages.

- Keep list requests paginated instead of trying to fetch everything at once.
- Retry `429` responses conservatively.
- Avoid parallel retry storms when polling or sweeping sessions.

Published guidance and client recommendations:

- `references/rate-limits.md`

## Operator Guidance

- Prefer workflow-backed session creation when business rules depend on a known step sequence.
- Use `external_id` consistently so integrations can look sessions up without storing only deepidv IDs.
- Treat redirect query parameters as a completion signal, then retrieve the session for authoritative analysis details when needed.
- Surface session IDs in logs and support diagnostics.

See the detailed references for contracts and operational guidance:

- `references/api-reference.md`
- `references/error-codes.md`
- `references/rate-limits.md`
- `scripts/verify.sh`
