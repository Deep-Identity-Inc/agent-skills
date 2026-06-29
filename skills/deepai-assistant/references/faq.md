# deepidv Integration FAQ

## General

**Q: What is deepidv?**
A: deepidv is an identity verification and compliance platform covering face
liveness, KYC, deepfake analysis, adverse-media screening, and AML or sanctions
checks.

**Q: Is there a sandbox environment?**
A: Yes. Use `https://api.deepidv.com/v1` with sandbox API keys. The key, not
the URL, determines whether traffic is sandbox or production.

## REST API and SDK

**Q: How do SDK and direct API calls authenticate?**
A: Use `x-api-key` with a deepidv API key.

**Q: What base URL should I use for the public API?**
A: `https://api.deepidv.com/v1`

**Q: Should I create workflows before sessions?**
A: Create or choose a workflow first when the business flow depends on a known
sequence of checks. Otherwise you can create a standalone session directly.

**Q: How do I handle rate limits?**
A: Treat `429` as a hard stop, back off, reduce concurrency, and avoid broad
polling or repeated full-list scans. These docs do not publish fixed numeric
quotas for the covered routes.

## Screening

**Q: Which screening calls are synchronous?**
A: `POST /v1/screening/pep-sanctions` and `POST /v1/screening/title-check`
return synchronously.

**Q: How does adverse-media screening work?**
A: `POST /v1/screening/adverse-media` queues a job and returns a `jobId`. Poll
`GET /v1/async-jobs/{jobId}` until the job reaches `ready` or `failed`.

**Q: Is `unsupported_region` from title check an error?**
A: No. It is a typed success result that tells the caller title search is
currently limited to US addresses.

## Hosted MCP

**Q: What MCP server URL should I install?**
A: `https://mcp.deepidv.com/v1/mcp`

**Q: What `client_id` should I use for hosted MCP?**
A: Use `deepidv` only if the MCP client explicitly asks for a `client_id`.

**Q: Do I need a `client_secret` for hosted MCP?**
A: No. The current hosted MCP flow uses a shared public OAuth client with PKCE,
so `client_secret` is not used.

**Q: Does hosted MCP use my API key?**
A: No. Hosted MCP uses OAuth sign-in with the user's deepidv account, not
`x-api-key`.

**Q: What if my MCP client requires a static `client_secret`?**
A: Treat that client as incompatible with deepidv's current hosted MCP auth
model.

## Compliance and Data Handling

**Q: What document types are generally supported for identity verification?**
A: The public product supports common government identity documents such as
passports, driver's licenses, and national ID cards. Match the exact workflow
configuration to the business requirement.

**Q: Is deepidv SOC 2 compliant?**
A: Yes. Contact `sales@deepidv.com` if a customer needs compliance collateral.

**Q: What should I log from verification or screening flows?**
A: Prefer status-level summaries, session IDs, workflow IDs, and job IDs. Avoid
logging full applicant PII, full artifacts, or raw adverse-media content unless
there is a specific operational need and an approved handling path.
