# DeepIDV MCP Server

Hosted MCP access to DeepIDV verification, workflow, financial, applicant, and screening tools.

## Features

- Manage verification sessions for your DeepIDV organization.
- Retrieve verification artifacts, timelines, and supporting resource links.
- Search applicants, inspect invitation status, and resend invitations.
- Create reusable workflows with DeepIDV verification steps.
- Review bank statement records, metrics, and create new statement requests.
- Run PEP and sanctions checks, title checks, adverse-media screening, and async job polling.
- Connect through hosted OAuth 2.0 with PKCE instead of running a local server.

## Quick Start

Use the hosted MCP endpoint:

- Server URL: `https://mcp.deepidv.com/v1/mcp`
- Server manifest: `https://mcp.deepidv.com/mcp.json`
- Protected resource metadata: `https://mcp.deepidv.com/.well-known/oauth-protected-resource`

Example prompts after installation:

- List my latest verification sessions.
- Find the applicant with email `jane@example.com`.
- Show the artifacts for verification session `<session_id>`.
- Run a PEP and sanctions check for Jane Doe born 1980-05-12.

If your MCP client supports remote HTTP servers with OAuth discovery, adding the
server URL is usually enough for the client to discover the DeepIDV OAuth
metadata automatically.

## Installation

DeepIDV is a hosted MCP server. You do not need to clone, build, or run a local
Node.js process to use it.

1. In your MCP client, add a remote server.
2. Enter `https://mcp.deepidv.com/v1/mcp` as the server URL.
3. If the client asks for `client_id`, use `deepidv`.
4. Do not enter a `client_secret`.
5. Complete the browser-based OAuth flow with your deepidv email and password,
   then MFA if required.
6. Ask your assistant to call a DeepIDV tool such as listing workflows,
   listing verification sessions, or running a screening check.

For installer-focused instructions, see [llms-install.md](llms-install.md).

## Authentication

DeepIDV uses hosted OAuth 2.0 with PKCE for MCP access.

The current hosted flow uses a shared public client:

- `client_id` is `deepidv`
- `client_secret` is not used
- token exchange uses PKCE with `S256`
- the user signs in with their deepidv email and password
- MFA is enforced when required by the account

Access is scoped to the authenticated DeepIDV user and organization. Tool calls
are validated against active account state before they run.

## Available Tools

### Applicants

| Tool                    | What it does                                                               |
| ----------------------- | -------------------------------------------------------------------------- |
| `search_applicants`     | Find matching applicants across sessions and bank statement requests.      |
| `get_applicant`         | Retrieve a consolidated applicant profile and history.                     |
| `get_invitation_status` | Check invitation delivery and engagement status.                           |
| `resend_invitation`     | Resend an invitation for a verification session or bank statement request. |

### Verification

| Tool                                 | What it does                                                        |
| ------------------------------------ | ------------------------------------------------------------------- |
| `list_verification_sessions`         | List verification sessions with filters and pagination.             |
| `get_session_stats`                  | Retrieve aggregated verification metrics and trends.                |
| `get_verification_session`           | Retrieve the full details for a verification session.               |
| `get_verification_session_artifacts` | Retrieve analysis data and resource links for a verification session. |
| `get_session_timeline`               | Retrieve a chronological timeline for one verification session.     |
| `create_verification_session`        | Create and send a new verification invitation.                      |
| `update_verification_session_status` | Manually mark a session as `VERIFIED` or `REJECTED`.                |
| `expire_session`                     | Expire an active verification session.                              |

### Workflows

| Tool              | What it does                                                            |
| ----------------- | ----------------------------------------------------------------------- |
| `list_workflows`  | List workflows available to the authenticated organization.             |
| `get_workflow`    | Retrieve one workflow and its configured steps.                         |
| `create_workflow` | Create a reusable workflow with one or more DeepIDV verification steps. |

Current workflow step IDs exposed through MCP:

- `ID_VERIFICATION`
- `FACE_LIVENESS`
- `AGE_ESTIMATION`
- `PEP_SANCTIONS`
- `ADVERSE_MEDIA`

### Financial

| Tool                                  | What it does                                                           |
| ------------------------------------- | ---------------------------------------------------------------------- |
| `list_bank_statements`                | List bank statement records for the authenticated organization.        |
| `get_bank_statement_stats`            | Retrieve aggregated bank statement metrics and trends.                 |
| `get_bank_statement`                  | Retrieve a bank statement record and statement details when available. |
| `list_bank_statements_by_external_id` | Retrieve bank statement records that match your external reference ID. |
| `create_bank_statement_request`       | Create and send a new bank statement request invitation.               |

### Silent Screening

| Tool                       | What it does                                                          |
| -------------------------- | --------------------------------------------------------------------- |
| `run_pep_sanctions_check`  | Run a synchronous PEP and sanctions screening.                        |
| `run_title_check`          | Run a synchronous property title or ownership search.                 |
| `run_adverse_media_check`  | Queue an asynchronous adverse-media screening and return a `job_id`.  |
| `get_async_job`            | Poll an async adverse-media screening job until it is ready or failed. |

## Requirements

You need:

- A DeepIDV account.
- An active DeepIDV user.
- Your deepidv email and password.
- MFA access if your account requires it.
- An MCP client that supports remote HTTP MCP servers with OAuth 2.0 authorization code and PKCE.

## How It Works

The public endpoint at `https://mcp.deepidv.com/v1/mcp` fronts the DeepIDV
hosted MCP transport. The server exposes DeepIDV platform operations over
streamable HTTP and uses the same core verification, workflow, financial, and
screening logic that powers the main platform.

For users, the important detail is simpler: connect once, authorize once, and
then call DeepIDV operations as MCP tools from your preferred client.

## Security Notes

- All MCP requests use bearer-token authentication.
- Access is limited to the authenticated DeepIDV organization and user.
- Tool calls are rate-limited.
- Some tools are state-changing and may create records, resend invites, or consume credits.
- Verification artifacts and returned links should be treated as sensitive customer data.

## Documentation

- Installation guide for marketplace agents: [llms-install.md](llms-install.md)
- DeepIDV website: [https://www.deepidv.com](https://www.deepidv.com)
- DeepIDV support: [https://www.deepidv.com/support](https://www.deepidv.com/support)

## Contributing

This folder documents the hosted DeepIDV MCP server for the public repository.
If you find a documentation issue, open a pull request or issue in the main
repository.

## License

This documentation is part of the main repository and covered by the repository
license.
