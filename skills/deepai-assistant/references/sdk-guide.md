# deepidv SDK and API Integration Guide

Use this guide when helping a developer wire deepidv into an application.

## Pick the Right Surface First

deepidv integrations typically use one of three surfaces:

- SDK or direct REST API for application-managed verification and screening
- hosted MCP for tool-based access inside an MCP-compatible client
- webhook or redirect handling for completion callbacks inside the caller's app

Keep the auth model aligned to the surface being used.

## REST API and SDK Auth

Use API-key authentication for SDK and direct REST integrations.

Base URL:

- `https://api.deepidv.com/v1`

Header:

```http
x-api-key: <api_key>
```

Suggested local credential lookup order:

1. `DEEPIDV_API_KEY`
2. `.deepidv/credentials` in the project root
3. `.deepidv/credentials` in the user home directory

Sandbox and production share the same base URL. The key determines which mode
the request runs in.

## Node.js Setup

```bash
npm install @deepidv/sdk
```

```javascript
import { DeepIDV } from "@deepidv/sdk";

const client = new DeepIDV({
  apiKey: process.env.DEEPIDV_API_KEY,
});
```

Example liveness call:

```javascript
const result = await client.verify.liveness({
  image: base64Image,
});

console.log(result.result.is_live);
```

## Python Setup

```bash
pip install deepidv
```

```python
import os
from deepidv import DeepIDV

client = DeepIDV(api_key=os.environ["DEEPIDV_API_KEY"])
```

## Canonical Workflow Patterns

### Start a Verification Journey

1. Discover or create the workflow.
2. Create the session with `POST /v1/sessions`.
3. Redirect the applicant to `session_url`.
4. Reconcile the final outcome with `GET /v1/sessions/{id}`.

### Run Screening

Use these public endpoints:

- `POST /v1/screening/pep-sanctions`
- `POST /v1/screening/title-check`
- `POST /v1/screening/adverse-media`
- `GET /v1/async-jobs/{jobId}`

Important:

- PEP and sanctions screening is synchronous.
- Title check is synchronous and returns typed `status` variants such as
  `found`, `multiple_properties`, `unsupported_region`, and `not_found`.
- Adverse-media screening is asynchronous and returns a `jobId` first.

### Workflows

Use workflows when business rules depend on a defined sequence of checks.

- Discover available workflows with `GET /v1/workflows`.
- Retrieve one workflow with `GET /v1/workflows/{id}` when the resolved config
  matters.
- Create a new workflow with `POST /v1/workflows` when the integration owns
  workflow provisioning.

## Hosted MCP Auth

Hosted MCP uses a different auth model from the REST API and SDK.

Server details:

- server URL: `https://mcp.deepidv.com/v1/mcp`
- server manifest: `https://mcp.deepidv.com/mcp.json`
- protected resource metadata:
  `https://mcp.deepidv.com/.well-known/oauth-protected-resource`

Current hosted auth model:

- `client_id`: `deepidv` if asked
- `client_secret`: not used
- sign-in: deepidv email, password, and MFA when required

Do not repurpose an API key as a hosted MCP `client_secret`.

## Configuration Notes

| Option | Type | Default | Notes |
| ------ | ---- | ------- | ----- |
| `apiKey` | string | - | Required for SDK and direct REST usage |
| `baseUrl` | string | `https://api.deepidv.com/v1` | Shared by sandbox and production |
| `timeout` | number | `30000` | Adjust for network conditions and long-running flows |
| `retries` | number | `3` | Use conservative retries for idempotent reads only |

## Practical Guidance

- Prefer direct session lookup over broad list polling when the session ID is
  already known.
- Reuse workflow discovery results instead of refetching the same workflow
  definitions repeatedly.
- Use an `Idempotency-Key` when retrying async adverse-media creation so the
  integration does not create duplicate screening jobs.
- Treat `429` as a signal to slow down rather than to fan out retries.

For exact request and response shapes, use the verify-skill reference files:

- `../../deepidv-verify/references/api-reference.md`
- `../../deepidv-verify/references/error-codes.md`
- `../../deepidv-verify/references/rate-limits.md`
