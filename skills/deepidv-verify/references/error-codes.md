# deepidv Error Codes

This catalog groups public Verify API failures by operator action so agents and integrators know how to recover safely.

## HTTP Failure Classes

| Status | Class                | Meaning                                                       | Operator Action                                                   |
| ------ | -------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------- |
| `400`  | Validation           | Request body is malformed or required fields are missing      | Validate JSON structure and required fields before retrying       |
| `401`  | Authentication       | API key is missing, invalid, revoked, or expired              | Refresh credentials and retry only after fixing authentication    |
| `403`  | Authorization        | The key does not have the required entitlement or scope       | Use a key with the correct permissions or update the account plan |
| `404`  | Routing              | The endpoint path is not valid                                | Correct the requested path or endpoint alias                      |
| `409`  | Idempotency          | The supplied `X-Request-ID` conflicts with a previous request | Reuse the existing request context or send a new request ID       |
| `413`  | Payload              | Media payload is too large                                    | Reduce payload size before retrying                               |
| `422`  | Processing           | Input is valid JSON but cannot be processed successfully      | Replace low-quality or unsupported media and retry                |
| `429`  | Rate Limit           | The caller has exceeded its quota or burst allowance          | Wait for `Retry-After` and retry conservatively                   |
| `500`  | Service Failure      | An unexpected server-side problem occurred                    | Retry with bounded exponential backoff and preserve `request_id`  |
| `503`  | Service Availability | The service is temporarily unavailable or under maintenance   | Wait for `Retry-After` before retrying                            |

## Application Error Codes

### Authentication and Authorization

| Error Code                | Meaning                                      | Operator Action                               |
| ------------------------- | -------------------------------------------- | --------------------------------------------- |
| `AUTH_KEY_MISSING`        | No API key was supplied                      | Add the `X-DEEPIDV-KEY` header                |
| `AUTH_KEY_INVALID`        | The supplied API key is not recognized       | Check for typos or rotate the key             |
| `AUTH_KEY_EXPIRED`        | The API key is no longer valid               | Generate a new key and retry                  |
| `AUTH_KEY_REVOKED`        | The key was revoked                          | Replace the revoked key                       |
| `AUTH_INSUFFICIENT_SCOPE` | The key cannot access the requested endpoint | Use a key with the right scope or entitlement |

### Validation and Request Shape

| Error Code               | Meaning                                      | Operator Action                     |
| ------------------------ | -------------------------------------------- | ----------------------------------- |
| `INVALID_JSON`           | Request body is not valid JSON               | Rebuild the payload with valid JSON |
| `PAYLOAD_TOO_LARGE`      | Request exceeds allowed payload size         | Compress or resize submitted media  |
| `SCREEN_NAME_REQUIRED`   | Screening request omitted `name`             | Supply a screening name             |
| `SCREEN_INVALID_COUNTRY` | Country code is not valid ISO 3166-1 alpha-2 | Use a valid two-letter country code |

### Liveness and Identity Processing

| Error Code                        | Meaning                                        | Operator Action                                 |
| --------------------------------- | ---------------------------------------------- | ----------------------------------------------- |
| `LIVENESS_NO_FACE`                | No face was detected in the image              | Capture a clearer image with one visible face   |
| `LIVENESS_MULTIPLE_FACES`         | More than one face was detected                | Resubmit with only one person in frame          |
| `LIVENESS_SPOOF_DETECTED`         | The capture appears spoofed                    | Re-run live capture in a controlled environment |
| `LIVENESS_LOW_QUALITY`            | Image quality is too low for liveness analysis | Increase resolution and lighting                |
| `IDENTITY_DOCUMENT_UNREADABLE`    | Document text or structure could not be parsed | Recapture the full document in focus            |
| `IDENTITY_DOCUMENT_EXPIRED`       | The document is expired                        | Use a valid, non-expired document               |
| `IDENTITY_DOCUMENT_UNSUPPORTED`   | Document type is unsupported                   | Use passport, driver's license, or national ID  |
| `IDENTITY_FACE_MISMATCH`          | Selfie does not match the document portrait    | Verify the subject or request a new capture     |
| `IDENTITY_DATA_EXTRACTION_FAILED` | OCR or extraction did not succeed              | Improve document image quality and retry        |

### Deepfake and Screening Processing

| Error Code                    | Meaning                                                     | Operator Action                                       |
| ----------------------------- | ----------------------------------------------------------- | ----------------------------------------------------- |
| `DEEPFAKE_UNSUPPORTED_FORMAT` | The submitted media format is unsupported                   | Use supported image or video formats                  |
| `DEEPFAKE_NO_FACE`            | No analyzable face was found in the media                   | Submit media with a clearly visible face              |
| `DEEPFAKE_MEDIA_CORRUPT`      | The media asset is corrupted                                | Re-encode or re-upload the media                      |
| `DEEPFAKE_TOO_SHORT`          | Video does not contain enough frames for analysis           | Submit a longer clip                                  |
| `SCREEN_SERVICE_UNAVAILABLE`  | Downstream screening data source is temporarily unavailable | Retry later and log the `request_id`                  |
| `RATE_LIMIT_EXCEEDED`         | Rate limit threshold was exceeded                           | Honor `Retry-After` before retrying                   |
| `INTERNAL_ERROR`              | Generic internal processing failure                         | Retry with bounded backoff, then escalate if repeated |

## Error Response Envelope

```json
{
  "request_id": "req_abc123",
  "status": "failed",
  "error": {
    "code": "LIVENESS_NO_FACE",
    "message": "No face detected in the image",
    "details": "Ensure the image contains a clearly visible face with adequate lighting."
  },
  "metadata": {
    "processing_ms": 45,
    "model_version": "2.1.0"
  }
}
```

## Recovery Guidance

- Do not blindly retry `400`, `401`, `403`, or `422` failures without changing the input or credentials.
- Retry `429`, `500`, and `503` only after waiting the required interval.
- Preserve `request_id` in logs and support escalations.
