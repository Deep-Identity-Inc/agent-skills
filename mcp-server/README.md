# DeepIDV MCP Server

Hosted MCP access to DeepIDV verification, workflow, and financial tools.

## Features

- Manage verification sessions for your DeepIDV organization.
- Retrieve verification artifacts and supporting resource links.
- Create reusable workflows with DeepIDV verification steps.
- Review bank statement records and create new statement requests.
- Connect through hosted OAuth 2.0 with PKCE instead of running a local server.

## Quick Start

Use the hosted MCP endpoint:

Server URL: https://mcp.deepidv.com/v1/mcp

Example prompts after installation:

- List my latest verification sessions.
- Show the artifacts for verification session <session_id>.
- Create a workflow named "Standard KYC" with ID verification and face liveness.

If your MCP client supports remote HTTP servers with OAuth, adding the URL lets the client discover the DeepIDV OAuth metadata automatically.

You must also provide DeepIDV OAuth client credentials:

- `client_id`: your DeepIDV user ID
- `client_secret`: any active DeepIDV API key owned by that same user

## Installation

DeepIDV is a hosted MCP server. You do not need to clone, build, or run a local Node.js process to use it.

1. In your MCP client, add a remote server.
2. Enter `https://mcp.deepidv.com/v1/mcp` as the server URL.
3. Enter your required OAuth credentials:
   - `client_id`: your DeepIDV user ID
   - `client_secret`: an active DeepIDV API key owned by that same user
4. Complete the OAuth flow when prompted.
5. Ask your assistant to call a DeepIDV tool such as listing workflows or verification sessions.

For installer-focused instructions, see [llms-install.md](llms-install.md).

## Authentication

DeepIDV uses hosted OAuth 2.0 with PKCE for MCP access.

`client_id` and `client_secret` are required for all MCP access. The browser OAuth approval flow does not replace these credentials; it runs alongside them.

Use:

- `client_id` is your DeepIDV user ID.
- `client_secret` is any active DeepIDV API key owned by that same user.

Access is scoped to the authenticated DeepIDV user and organization. Tool calls are validated against active account state before they run.

## Available Tools

### Verification

| Tool                                 | What it does                                                                                   |
| ------------------------------------ | ---------------------------------------------------------------------------------------------- |
| `list_verification_sessions`         | List verification sessions with optional filters such as date range, workflow, or external ID. |
| `get_verification_session`           | Retrieve the full details for a verification session.                                          |
| `get_verification_session_artifacts` | Retrieve analysis data and resource links for a verification session.                          |
| `create_verification_session`        | Create and send a new verification invitation.                                                 |
| `update_verification_session_status` | Manually mark a session as `VERIFIED` or `REJECTED`.                                           |

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
| `get_bank_statement`                  | Retrieve a bank statement record and statement details when available. |
| `list_bank_statements_by_external_id` | Retrieve bank statement records that match your external reference ID. |
| `create_bank_statement_request`       | Create and send a new bank statement request invitation.               |

## Requirements

You need:

- A DeepIDV account.
- An active DeepIDV user.
- An active API key for that same user.
- An MCP client that supports remote HTTP MCP servers with OAuth.

## How It Works

The public endpoint at `https://mcp.deepidv.com/v1/mcp` fronts the DeepIDV hosted MCP transport. The server exposes DeepIDV platform operations over streamable HTTP and uses the same core verification, workflow, and financial logic that powers the main platform.

For users, the important detail is simpler: connect once, authorize once, and then call DeepIDV operations as MCP tools from your preferred client.

## Security Notes

- All MCP requests use bearer-token authentication.
- Access is limited to the authenticated DeepIDV organization and user.
- Tool calls are rate-limited.
- Verification artifacts and returned links should be treated as sensitive customer data.

## Documentation

- Installation guide for marketplace agents: [llms-install.md](llms-install.md)
- DeepIDV website: [https://www.deepidv.com](https://www.deepidv.com)
- DeepIDV support: [https://www.deepidv.com/support](https://www.deepidv.com/support)

## Contributing

This folder documents the hosted DeepIDV MCP server for the public repository. If you find a documentation issue, open a pull request or issue in the main repository.

## License

This documentation is part of the main repository and covered by the repository license.
