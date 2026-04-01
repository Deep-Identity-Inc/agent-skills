# deepidv Sessions and Workflows Rate-Limit Guidance

This document summarizes the rate-limit behavior that is explicitly visible from the deepidv docs pages covering sessions and workflows.

## Published Behavior

The current docs pages for session and workflow endpoints publish `429 Too Many Requests` as an error response.

Covered endpoints:

- `POST /v1/sessions`
- `GET /v1/sessions`
- `GET /v1/sessions/{id}`
- `PATCH /v1/sessions/{id}/update-status`
- `POST /v1/workflows`
- `GET /v1/workflows`
- `GET /v1/workflows/{id}`

The docs pages do not publish numeric per-minute quotas, burst allowances, or response header contracts for these endpoints. Clients should avoid assuming undocumented limits.

## Safe Client Expectations

- Treat `429` as a hard stop, not as a prompt to increase retry pressure.
- Keep session listing paginated and bounded. The documented `limit` range is `1` to `500`, with `50` as the default.
- Avoid concurrent polling loops that hit the same session or workflow repeatedly.
- Cache workflow lists and workflow definitions when the same data would otherwise be fetched repeatedly.
- Reuse `GET /v1/workflows` results for workflow discovery because list responses include step sequences.
- Use `external_id` and `workflow_id` filters to reduce unnecessary page scans on `GET /v1/sessions`.

## Recommended Retry Policy

1. On `429`, wait before retrying and reduce concurrency.
2. Retry only the specific request that was throttled.
3. If listing sessions, resume from the last known `next_token` rather than restarting the full scan.
4. If repeated throttling occurs, lower background polling frequency and cache more aggressively.

## Operational Advice

- Resolve workflow IDs once, then reuse them during session creation.
- Prefer direct lookups such as `GET /v1/sessions/{id}` or `GET /v1/sessions?external_id=...` over broad list sweeps when you already know the target.
- Prefer `GET /v1/workflows/{id}` only when you need fully resolved step configuration beyond the list response.
- If a redirect flow already returned a `session_id`, retrieve that single session instead of polling organization-wide lists.
