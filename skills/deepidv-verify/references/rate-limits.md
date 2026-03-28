# deepidv Rate Limits

This document describes the published rate-limit posture for the public deepidv Verify API and the safe retry behavior expected from clients.

## Published Limits

| Plan            | Requests per Minute | Burst Allowance | Daily Limit |
| --------------- | ------------------- | --------------- | ----------- |
| Free or Sandbox | 10                  | 20              | 100         |
| Starter         | 30                  | 60              | 5000        |
| Growth          | 100                 | 200             | 50000       |
| Enterprise      | Custom              | Custom          | Custom      |

Sandbox traffic always uses the Free or Sandbox tier, even if the production account has higher throughput.

## Response Headers

| Header                  | Meaning                                                              |
| ----------------------- | -------------------------------------------------------------------- |
| `X-RateLimit-Limit`     | Requests allowed in the current minute window                        |
| `X-RateLimit-Remaining` | Requests remaining in the current minute window                      |
| `X-RateLimit-Reset`     | Unix timestamp for the next window reset                             |
| `Retry-After`           | Seconds to wait before retrying after throttling or temporary outage |

## Safe Client Expectations

- Treat `429` as a signal to stop sending requests until `Retry-After` has elapsed.
- Do not fan out retries across parallel workers after throttling.
- Preserve the same `X-Request-ID` only when retrying the same logical request.
- Use bounded exponential backoff for `500` and `503` responses.
- Log `request_id`, `X-RateLimit-Remaining`, and `Retry-After` for operator diagnostics.

## Recommended Retry Policy

1. If `Retry-After` is present, wait exactly that duration.
2. If `Retry-After` is missing for a retriable response, wait `1`, `2`, then `4` seconds.
3. Stop after three retries unless an operator explicitly opts into longer retries.
4. Do not retry validation or authentication failures.

Example pseudocode:

```python
import time
import requests


def call_with_retry(url, headers, body, max_retries=3):
    delay = 1
    for attempt in range(max_retries + 1):
        response = requests.post(url, headers=headers, json=body)
        if response.status_code not in (429, 500, 503):
            return response
        retry_after = response.headers.get("Retry-After")
        wait_seconds = int(retry_after) if retry_after else delay
        time.sleep(wait_seconds)
        delay = min(delay * 2, 4)
    return response
```

## Endpoint Pooling

All six public Verify endpoints share the same account-level quota pool. There are no endpoint-specific pools for the public skill.

## Operational Advice

- Prefer the combined verification endpoint when a workflow would otherwise issue several back-to-back requests for the same subject.
- Run load tests only against sandbox and within published sandbox limits.
- Contact deepidv sales or support before planning throughput above the published tier.
