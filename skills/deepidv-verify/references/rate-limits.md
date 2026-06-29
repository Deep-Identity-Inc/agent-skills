# deepidv Sessions, Workflows, and Screening Rate-Limit Guidance

This document summarizes the rate-limit behavior that is explicitly visible from
the deepidv docs pages used by this skill.

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

## Published Behavior

The current docs pages expose `429 Too Many Requests` for these endpoints.

The docs do not publish fixed numeric quotas, burst allowances, or a guaranteed
response-header contract for these routes. Clients should not assume
undocumented limits.

## Safe Client Expectations

- Treat `429` as a hard stop, not a signal to increase retry pressure.
- Keep session listing paginated and bounded. The documented `limit` range is
  `1` to `500`, with `50` as the default.
- Cache workflow lists and workflow definitions when the same data would
  otherwise be fetched repeatedly.
- Reuse `GET /v1/workflows` results for workflow discovery because list
  responses already include step sequences.
- Use `external_id` and `workflow_id` filters to reduce broad `GET /v1/sessions`
  scans.
- Avoid concurrent polling loops against the same async `jobId`.
- Use `Idempotency-Key` for adverse-media requests when a retry could otherwise
  create duplicate work.

## Recommended Retry Policy

1. On `429`, wait before retrying and reduce concurrency.
2. Retry only the specific request that was throttled.
3. If listing sessions, resume from the last known `next_token` instead of
   restarting the full scan.
4. If polling an async job, increase the delay between attempts instead of
   tight-loop polling.
5. If repeated throttling occurs, lower background polling frequency and cache
   more aggressively.

## Operational Advice

- Resolve workflow IDs once, then reuse them during session creation.
- Prefer direct lookups such as `GET /v1/sessions/{id}` or
  `GET /v1/sessions?external_id=...` over broad list sweeps when you already
  know the target.
- Prefer `GET /v1/workflows/{id}` only when you need fully resolved step
  configuration beyond the list response.
- If a redirect flow already returned a `session_id`, retrieve that single
  session instead of polling organization-wide lists.
- For adverse-media screening, queue the job once and then poll the returned
  `jobId` conservatively until it reaches `ready` or `failed`.
