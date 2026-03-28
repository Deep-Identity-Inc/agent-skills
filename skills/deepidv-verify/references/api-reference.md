# deepidv Verify API Reference

This document is the detailed request and response contract reference for the public deepidv Verify skill.

## Base URLs

| Environment | Base URL                             | Key Guidance                   |
| ----------- | ------------------------------------ | ------------------------------ |
| Production  | `https://api.deepidv.com/v1`         | Use live keys for real traffic |
| Sandbox     | `https://sandbox.api.deepidv.com/v1` | Use sandbox keys for testing   |

## Authentication

All requests require the `X-DEEPIDV-KEY` header.

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

| Header          | Required | Description                                                     |
| --------------- | -------- | --------------------------------------------------------------- |
| `Content-Type`  | Yes      | Must be `application/json`                                      |
| `X-DEEPIDV-KEY` | Yes      | deepidv API key                                                 |
| `X-Request-ID`  | No       | Optional caller-supplied request correlation or idempotency key |

## Common Response Envelope

Every endpoint returns the same top-level envelope.

```json
{
  "request_id": "req_abc123",
  "status": "completed",
  "result": {},
  "risk_score": 8,
  "metadata": {
    "processing_ms": 247,
    "model_version": "2.1.0"
  }
}
```

| Field                    | Type    | Meaning                                |
| ------------------------ | ------- | -------------------------------------- |
| `request_id`             | string  | Unique request trace identifier        |
| `status`                 | string  | `completed`, `pending`, or `failed`    |
| `result`                 | object  | Endpoint-specific result payload       |
| `risk_score`             | integer | Aggregate risk score from `0` to `100` |
| `metadata.processing_ms` | integer | Processing duration in milliseconds    |
| `metadata.model_version` | string  | Model release used for the request     |

## Endpoint Contracts

### 1. Face Liveness

`POST /v1/verify/liveness`

Use this endpoint when the caller needs proof-of-life for a selfie or captured face frame.

Request body:

| Field                   | Type    | Required | Default    | Description                                      |
| ----------------------- | ------- | -------- | ---------- | ------------------------------------------------ |
| `image`                 | string  | Yes      | None       | Base64-encoded image or extracted video frame    |
| `options.strictness`    | string  | No       | `standard` | `low`, `standard`, or `high`                     |
| `options.return_frames` | boolean | No       | `false`    | Include frame-level analysis for video workflows |

Example request:

```json
{
  "image": "<base64_image>",
  "options": {
    "strictness": "standard",
    "return_frames": false
  }
}
```

Response `result`:

| Field            | Type           | Meaning                                                         |
| ---------------- | -------------- | --------------------------------------------------------------- |
| `is_live`        | boolean        | Whether the face passed proof-of-life                           |
| `liveness_score` | integer        | Confidence score from `0` to `100`                              |
| `confidence`     | string         | `low`, `medium`, or `high`                                      |
| `spoof_type`     | string or null | Attack type such as `printed_photo`, `screen_replay`, or `mask` |
| `frame_analysis` | array          | Per-frame detail when requested                                 |

### 2. Identity Verification

`POST /v1/verify/identity`

Use this endpoint for KYC, document verification, and selfie-to-document face matching.

Request body:

| Field                     | Type    | Required | Default | Description                                             |
| ------------------------- | ------- | -------- | ------- | ------------------------------------------------------- |
| `document.image`          | string  | Yes      | None    | Base64-encoded document image                           |
| `document.type`           | string  | No       | `auto`  | `passport`, `drivers_license`, `national_id`, or `auto` |
| `selfie`                  | string  | Yes      | None    | Base64-encoded selfie image                             |
| `options.extract_data`    | boolean | No       | `true`  | Extract machine-readable identity fields                |
| `options.match_threshold` | integer | No       | `80`    | Minimum acceptable face-match score                     |

Example request:

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

Response `result`:

| Field                   | Type    | Meaning                             |
| ----------------------- | ------- | ----------------------------------- |
| `verified`              | boolean | Primary pass or fail outcome        |
| `face_match_score`      | integer | Selfie-to-document face match score |
| `document_type`         | string  | Detected or supplied document type  |
| `extracted_data`        | object  | Parsed identity fields              |
| `document_authenticity` | object  | Authenticity checks and confidence  |

### 3. Deepfake Detection

`POST /v1/verify/deepfake`

Use this endpoint when the media itself needs authenticity analysis.

Request body:

| Field                       | Type    | Required | Default | Description                   |
| --------------------------- | ------- | -------- | ------- | ----------------------------- |
| `media`                     | string  | Yes      | None    | Base64-encoded image or video |
| `media_type`                | string  | Yes      | None    | `image` or `video`            |
| `options.detailed_analysis` | boolean | No       | `false` | Include artifact-level detail |

Example request:

```json
{
  "media": "<base64_media>",
  "media_type": "image",
  "options": {
    "detailed_analysis": true
  }
}
```

Response `result`:

| Field                  | Type           | Meaning                                                                          |
| ---------------------- | -------------- | -------------------------------------------------------------------------------- |
| `is_deepfake`          | boolean        | Whether manipulation is likely present                                           |
| `deepfake_probability` | integer        | Probability score from `0` to `100`                                              |
| `manipulation_type`    | string or null | `face_swap`, `full_synthetic`, `audio_deepfake`, `partial_manipulation`, or null |
| `artifact_analysis`    | object         | Detailed anomaly indicators                                                      |

### 4. Adverse Media Screening

`POST /v1/screen/adverse-media`

Use this endpoint when public reporting and reputational risk must be reviewed.

Request body:

| Field                   | Type    | Required | Default | Description                                                                     |
| ----------------------- | ------- | -------- | ------- | ------------------------------------------------------------------------------- |
| `name`                  | string  | Yes      | None    | Person or entity name                                                           |
| `date_of_birth`         | string  | No       | None    | ISO `YYYY-MM-DD` date                                                           |
| `nationality`           | string  | No       | None    | ISO 3166-1 alpha-2 code                                                         |
| `options.categories`    | array   | No       | all     | Categories such as `fraud`, `terrorism`, `financial_crime`, `sanctions_evasion` |
| `options.date_range`    | string  | No       | `5y`    | `1y`, `3y`, `5y`, `10y`, or `all`                                               |
| `options.min_relevance` | integer | No       | `70`    | Minimum relevance score                                                         |

Example request:

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

Response `result`:

| Field              | Type    | Meaning                              |
| ------------------ | ------- | ------------------------------------ |
| `hits`             | integer | Number of adverse media matches      |
| `matches`          | array   | Matching articles and public records |
| `screened_sources` | integer | Number of sources checked            |

### 5. AML and Sanctions Screening

`POST /v1/screen/aml`

Use this endpoint for sanctions, PEP, and watchlist checks.

Request body:

| Field                        | Type    | Required | Default | Description                             |
| ---------------------------- | ------- | -------- | ------- | --------------------------------------- |
| `name`                       | string  | Yes      | None    | Person or entity name                   |
| `date_of_birth`              | string  | No       | None    | ISO `YYYY-MM-DD` date                   |
| `nationality`                | string  | No       | None    | ISO 3166-1 alpha-2 code                 |
| `screening_types`            | array   | No       | all     | Any of `sanctions`, `pep`, `watchlists` |
| `options.fuzzy_threshold`    | integer | No       | `85`    | Minimum fuzzy-match score               |
| `options.include_associates` | boolean | No       | `false` | Include known associates                |

Example request:

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

Response `result`:

| Field                | Type           | Meaning                     |
| -------------------- | -------------- | --------------------------- |
| `hits`               | integer        | Number of watchlist matches |
| `matches`            | array          | Matching watchlist records  |
| `lists_checked`      | integer        | Number of lists queried     |
| `pep_classification` | string or null | PEP type when applicable    |

### 6. Combined Verification

`POST /v1/verify/full`

Use this endpoint when a caller wants a complete verification workflow in one request.

Request body:

| Field                     | Type   | Required | Default    | Description                   |
| ------------------------- | ------ | -------- | ---------- | ----------------------------- |
| `document.image`          | string | Yes      | None       | Base64-encoded document image |
| `document.type`           | string | No       | `auto`     | Document type override        |
| `selfie`                  | string | Yes      | None       | Base64-encoded selfie         |
| `screening.name`          | string | Yes      | None       | Name used for screening       |
| `screening.date_of_birth` | string | No       | None       | ISO `YYYY-MM-DD` date         |
| `screening.nationality`   | string | No       | None       | ISO 3166-1 alpha-2 code       |
| `options.skip`            | array  | No       | `[]`       | Optional checks to skip       |
| `options.strictness`      | string | No       | `standard` | Liveness strictness profile   |

Example request:

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

Response `result`:

| Field              | Type   | Meaning                             |
| ------------------ | ------ | ----------------------------------- |
| `overall_decision` | string | `approved`, `review`, or `rejected` |
| `liveness`         | object | Liveness sub-result                 |
| `identity`         | object | Identity sub-result                 |
| `deepfake`         | object | Deepfake sub-result                 |
| `adverse_media`    | object | Adverse media sub-result            |
| `aml`              | object | AML and sanctions sub-result        |

## Notes for Safe Clients

- Always send JSON request bodies.
- Reuse `X-Request-ID` only when intentionally retrying the same logical request.
- Treat `pending` as non-final and wait for downstream orchestration to finish.
- Surface `request_id` in logs and support tickets.
