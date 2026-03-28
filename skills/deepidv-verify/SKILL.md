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

| User Intent                                                    | Endpoint                        |
| -------------------------------------------------------------- | ------------------------------- |
| Confirm the selfie came from a live person                     | `POST /v1/verify/liveness`      |
| Verify a government ID against a selfie                        | `POST /v1/verify/identity`      |
| Check whether an image or video is AI-generated or manipulated | `POST /v1/verify/deepfake`      |
| Search news and public reports for adverse media risk          | `POST /v1/screen/adverse-media` |
| Screen against sanctions, PEP, and watchlists                  | `POST /v1/screen/aml`           |
| Run a complete verification and screening flow in one call     | `POST /v1/verify/full`          |

Do not ask the user to choose an endpoint if the request already implies the correct capability.

## Authentication

All requests require API-key authentication with the `X-DEEPIDV-KEY` header.

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
X-DEEPIDV-KEY: <api_key>
```

Never commit keys to the repository. Use sandbox keys for testing and live keys for production traffic.

## Base URL

| Environment | Base URL                             | Intended Key Type |
| ----------- | ------------------------------------ | ----------------- |
| Production  | `https://api.deepidv.com/v1`         | Live key          |
| Sandbox     | `https://sandbox.api.deepidv.com/v1` | Sandbox key       |

The skill supports sandbox and production without code changes:

- Set `DEEPIDV_ENV=sandbox` to target sandbox.
- Set `DEEPIDV_ENV=production` to target production.
- Set `DEEPIDV_BASE_URL` only when you need an explicit override.

## Sandbox Mode

Use sandbox for testing request construction, endpoint selection, and response handling without sending production traffic.

- Use sandbox keys against `https://sandbox.api.deepidv.com/v1`.
- Use test media and non-production identity data when validating flows.
- Expect the same top-level response envelope as production, including `request_id`, `status`, `result`, `risk_score`, and `metadata`.
- Validate retry behavior and throttling assumptions against sandbox before promoting a workflow to production.

## Endpoint Reference

### Common Request Pattern

All endpoints accept JSON request bodies.

```http
POST {base_url}/{path}
Content-Type: application/json
X-DEEPIDV-KEY: <api_key>
X-Request-ID: <optional_uuid>
```

`X-Request-ID` is optional and should be supplied when callers want request correlation or idempotent retry behavior.

### Common Response Envelope

```json
{
  "request_id": "req_abc123",
  "status": "completed",
  "result": {},
  "risk_score": 12,
  "metadata": {
    "processing_ms": 247,
    "model_version": "2.1.0"
  }
}
```

Status values:

- `completed`: the result is final and ready to use.
- `pending`: processing has started but the result is not final yet.
- `failed`: the request could not be completed.

### Capability Guide

| Capability                  | Endpoint                        | Use When                                                     | Required Inputs                              | Optional Inputs                                                                            | Response Meaning                                                                                | Notable Risk or Decision Fields                                                                                                        |
| --------------------------- | ------------------------------- | ------------------------------------------------------------ | -------------------------------------------- | ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Face Liveness               | `POST /v1/verify/liveness`      | You need proof-of-life from a selfie or capture frame        | `image`                                      | `options.strictness`, `options.return_frames`                                              | Reports whether the face appears live or spoofed                                                | `result.is_live`, `result.liveness_score`, `result.spoof_type`, `risk_score`                                                           |
| Identity Verification       | `POST /v1/verify/identity`      | You need document verification and face match for KYC        | `document.image`, `selfie`                   | `document.type`, `options.extract_data`, `options.match_threshold`                         | Reports whether the identity check passed, extracted identity fields, and document authenticity | `result.verified`, `result.face_match_score`, `result.document_authenticity`, `risk_score`                                             |
| Deepfake Detection          | `POST /v1/verify/deepfake`      | You need to assess whether media is manipulated or synthetic | `media`, `media_type`                        | `options.detailed_analysis`                                                                | Reports whether deepfake indicators were found and how likely manipulation is                   | `result.is_deepfake`, `result.deepfake_probability`, `result.manipulation_type`, `risk_score`                                          |
| Adverse Media Screening     | `POST /v1/screen/adverse-media` | You need reputational and public-reporting risk checks       | `name`                                       | `date_of_birth`, `nationality`, screening filters                                          | Returns adverse media hits and relevance scores                                                 | `result.hits`, `result.matches`, `risk_score`                                                                                          |
| AML and Sanctions Screening | `POST /v1/screen/aml`           | You need sanctions, PEP, or watchlist screening              | `name`                                       | `date_of_birth`, `nationality`, `screening_types`, AML options                             | Returns watchlist hits, list coverage, and PEP classification                                   | `result.hits`, `result.matches`, `result.pep_classification`, `risk_score`                                                             |
| Combined Verification       | `POST /v1/verify/full`          | You want one call to run verification plus screening         | `document.image`, `selfie`, `screening.name` | `document.type`, `screening.date_of_birth`, `screening.nationality`, orchestration options | Returns a combined decision and sub-results for each verification step                          | `result.overall_decision`, `result.liveness`, `result.identity`, `result.deepfake`, `result.adverse_media`, `result.aml`, `risk_score` |

### Endpoint Details

### Face Liveness

`POST /v1/verify/liveness`

Use when a workflow must confirm the selfie or capture frame came from a live person instead of a printout, replay, or mask.

Representative request:

```json
{
  "image": "<base64_image>",
  "options": {
    "strictness": "standard",
    "return_frames": false
  }
}
```

High-level response meaning:

- `result.is_live` states whether the capture passed proof-of-life.
- `result.liveness_score` expresses confidence.
- `result.spoof_type` explains the suspected attack when the check fails.

### Identity Verification

`POST /v1/verify/identity`

Use when onboarding, step-up verification, or re-verification requires document inspection plus selfie matching.

Representative request:

```json
{
  "document": {
    "image": "<base64_document_image>",
    "type": "passport"
  },
  "selfie": "<base64_selfie>",
  "options": {
    "extract_data": true,
    "match_threshold": 80
  }
}
```

High-level response meaning:

- `result.verified` is the primary pass or fail signal.
- `result.face_match_score` measures selfie-to-document match strength.
- `result.document_authenticity` surfaces authenticity checks that may require review.

### Deepfake Detection

`POST /v1/verify/deepfake`

Use when image or video authenticity matters and AI manipulation needs to be ruled out.

Representative request:

```json
{
  "media": "<base64_media>",
  "media_type": "image",
  "options": {
    "detailed_analysis": true
  }
}
```

High-level response meaning:

- `result.is_deepfake` indicates whether the media is likely manipulated.
- `result.deepfake_probability` quantifies the likelihood of synthetic content.
- `result.manipulation_type` helps route manual review.

### Adverse Media Screening

`POST /v1/screen/adverse-media`

Use when reputational risk or negative-publicity checks are required for a person or entity.

Representative request:

```json
{
  "name": "Jane Doe",
  "date_of_birth": "1990-05-15",
  "nationality": "CA",
  "options": {
    "categories": ["fraud", "financial_crime"],
    "date_range": "5y",
    "min_relevance": 70
  }
}
```

High-level response meaning:

- `result.hits` indicates whether any relevant records were found.
- `result.matches` contains the news or reporting evidence to review.
- `risk_score` provides a single risk signal for downstream policy.

### AML and Sanctions Screening

`POST /v1/screen/aml`

Use when regulatory compliance requires sanctions, PEP, or watchlist screening.

Representative request:

```json
{
  "name": "Jane Doe",
  "date_of_birth": "1990-05-15",
  "nationality": "CA",
  "screening_types": ["sanctions", "pep"],
  "options": {
    "fuzzy_threshold": 85,
    "include_associates": false
  }
}
```

High-level response meaning:

- `result.hits` reports match count.
- `result.matches` holds the supporting list entries.
- `result.pep_classification` flags politically exposed persons when applicable.

### Combined Verification

`POST /v1/verify/full`

Use when the caller wants one orchestrated verification call instead of sequencing multiple endpoints.

Representative request:

```json
{
  "document": {
    "image": "<base64_document_image>",
    "type": "passport"
  },
  "selfie": "<base64_selfie>",
  "screening": {
    "name": "Jane Doe",
    "date_of_birth": "1990-05-15",
    "nationality": "CA"
  },
  "options": {
    "skip": [],
    "strictness": "standard"
  }
}
```

High-level response meaning:

- `result.overall_decision` is the combined approval, review, or rejection output.
- The sub-results identify which control raised risk.
- `risk_score` gives the aggregate risk signal for workflow automation.

## Workflows

### Full KYC Onboarding

1. Use `POST /v1/verify/full` when the caller already has document, selfie, and screening inputs.
2. Use `POST /v1/verify/liveness` first when proof-of-life must be enforced before document capture.
3. Follow with `POST /v1/verify/identity` if the flow needs standalone document verification evidence.

### Media Authenticity Review

1. Use `POST /v1/verify/deepfake` for the media.
2. Escalate to manual review when `result.is_deepfake` is true or `risk_score` exceeds internal thresholds.

### Compliance Screening Only

1. Use `POST /v1/screen/aml` for sanctions, PEP, and watchlists.
2. Use `POST /v1/screen/adverse-media` when reputational screening is also required.

## Error Handling

Use the API response `status` together with the HTTP status code to decide whether to retry, correct inputs, or escalate.

| HTTP Status | Meaning                                       | Action                                                         |
| ----------- | --------------------------------------------- | -------------------------------------------------------------- |
| `400`       | Invalid request body or missing required data | Fix the request shape before retrying                          |
| `401`       | Missing or invalid API key                    | Refresh credentials and retry only after fixing authentication |
| `403`       | Key lacks required permissions                | Use a key with the correct scope or entitlement                |
| `422`       | Input cannot be processed successfully        | Replace unsupported or low-quality media and retry             |
| `429`       | Rate limit exceeded                           | Wait for `Retry-After` before retrying                         |
| `500`       | Unexpected service-side failure               | Retry with bounded exponential backoff                         |
| `503`       | Temporary service unavailability              | Wait for `Retry-After` before retrying                         |

Use the detailed error catalog for endpoint-specific recovery guidance:

- [Error codes](references/error-codes.md)

## Rate Limits

All six public Verify endpoints share the same account-level quota pool.

- Sandbox traffic uses the Free or Sandbox tier limits.
- Check `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`, and `Retry-After` response headers.
- Stop and wait when throttled instead of retrying in parallel.

Published limit and retry guidance:

- [Rate limits](references/rate-limits.md)

## Operator Guidance

- Treat `pending` responses as incomplete and continue polling or workflow orchestration outside this skill.
- Respect `Retry-After` on `429` and `503` responses.
- Surface `request_id` in logs or user-visible diagnostics so support teams can trace requests.

See the detailed references for contracts and operational guidance:

- [API reference](references/api-reference.md)
- [Error codes](references/error-codes.md)
- [Rate limits](references/rate-limits.md)
- [CLI wrapper](scripts/verify.sh)
