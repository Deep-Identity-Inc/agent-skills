# deepidv TypeScript Server SDK and API Integration Guide

Use this guide when helping a developer wire deepidv into an application.

## Pick the Right Surface First

deepidv integrations typically use one of three surfaces:

- `@deepidv/server` for backend TypeScript verification and screening flows
- direct REST API for explicit HTTP integration work
- hosted MCP for tool-based access inside an MCP-compatible client

Keep the auth model aligned to the surface being used.

## REST API and SDK Auth

Use API-key authentication for SDK and direct REST integrations.

REST base URL:

- `https://api.deepidv.com/v1`

Header:

```http
x-api-key: <api_key>
```

Suggested local credential lookup order:

1. `DEEPIDV_API_KEY`
2. `.deepidv/credentials` in the project root
3. `.deepidv/credentials` in the user home directory

Sandbox and production share the same API hostname. The key determines which
mode the request runs in.

## Canonical TypeScript Package

For backend TypeScript integrations, use `@deepidv/server`.

```bash
npm install @deepidv/server
```

```bash
pnpm add @deepidv/server
```

```bash
yarn add @deepidv/server
```

```bash
bun add @deepidv/server
```

This SDK is backend-first. Keep it in a trusted server, worker, or edge runtime
and do not ship it to a browser or mobile client.

## TypeScript Setup

```typescript
import { DeepIDV } from '@deepidv/server';

const client = new DeepIDV({
  apiKey: process.env.DEEPIDV_API_KEY!,
});
```

## Namespace Map

Use the documented namespaces only:

| Namespace | Methods | Use it for |
| --------- | ------- | ---------- |
| `client.sessions` | `create`, `retrieve`, `list`, `updateStatus` | Hosted verification sessions |
| `client.document` | `scan` | Document OCR and extraction |
| `client.face` | `detect`, `compare`, `estimateAge` | Face primitives |
| `client.identity` | `verify` | One-call identity verification |
| `client.screening` | `pepSanctions`, `titleCheck`, `adverseMedia` | Silent screening |
| `client.asyncJobs` | `get` | Poll long-running async jobs |

Do not invent undocumented SDK namespaces such as `client.workflows.*`. If the
developer needs workflow management, use the REST management API docs unless a
published SDK surface exists.

### Example hosted session flow

```typescript
const session = await client.sessions.create({
  firstName: 'Jane',
  lastName: 'Doe',
  email: 'jane@example.com',
  phone: '+15551234567',
});

console.log(session.sessionUrl);
```

### Example server-to-server flow

```typescript
import { readFileSync } from 'node:fs';

const verification = await client.identity.verify({
  documentImage: readFileSync('passport.jpg'),
  faceImage: readFileSync('selfie.jpg'),
});

console.log(verification.verified);
console.log(verification.overallConfidence);
```

## Canonical Workflow Patterns

### Start a Verification Journey

1. Create the session with `client.sessions.create(...)`.
2. Redirect the applicant to `session.sessionUrl`.
3. Reconcile the final outcome with `client.sessions.retrieve(session.id)`.
4. Update the final status with `client.sessions.updateStatus(...)` if needed.

If the developer already has a workflow ID, pass it as `workflowId` during
session creation.

### Run Screening

Use these documented SDK methods:

- `client.screening.pepSanctions(...)`
- `client.screening.titleCheck(...)`
- `client.screening.adverseMedia(...)`
- `client.asyncJobs.get(jobId)`

Important:

- PEP and sanctions screening is synchronous.
- Title check is synchronous and returns typed `status` variants such as
  `found`, `multiple_properties`, `unsupported_region`, and `not_found`.
- Adverse-media screening is asynchronous and returns a handle or `jobId`
  first.
- `pepSanctions` and `titleCheck` fail fast on `503` rather than auto-retrying
  through the SDK.

### Workflows

Use workflows when business rules depend on a defined sequence of checks.

- Pass `workflowId` to `client.sessions.create(...)` when a workflow is already
  defined.
- Use the REST management API docs when the integration needs workflow
  creation, listing, or retrieval.

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
| `baseUrl` | string | `https://api.deepidv.com` | SDK constructor default |
| `timeout` | number | `30000` | Per-attempt API timeout |
| `uploadTimeout` | number | `120000` | Per-attempt upload timeout |
| `maxRetries` | number | `3` | Automatic retries for `429` and `5xx` where supported |
| `initialRetryDelay` | number | `500` | Base delay for exponential backoff |

## Practical Guidance

- Prefer direct session lookup over broad list polling when the session ID is
  already known.
- Reuse workflow discovery results instead of refetching the same workflow
  definitions repeatedly.
- Use an `Idempotency-Key` when retrying async adverse-media creation so the
  integration does not create duplicate screening jobs.
- Treat `429` as a signal to slow down rather than to fan out retries.
- Handle typed SDK errors explicitly, especially `AuthenticationError`,
  `RateLimitError`, `TimeoutError`, `ServiceUnavailableError`,
  `AdverseMediaFailedError`, and `PollTimeoutError`.

For exact request and response shapes, use the verify-skill reference files:

- `../../deepidv-verify/references/api-reference.md`
- `../../deepidv-verify/references/error-codes.md`
- `../../deepidv-verify/references/rate-limits.md`
