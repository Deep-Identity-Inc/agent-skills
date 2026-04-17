# DeepIDV MCP Installation Guide for Agents

Use this file when you are installing the DeepIDV MCP server for a user from this repository.

## Goal

Connect the user to the hosted DeepIDV MCP server at `https://mcp.deepidv.com/v1/mcp`.

Do not build or run a local server from this repository for normal setup. This MCP server is already hosted by DeepIDV.

Client credentials are mandatory for access.

## Server Details

| Setting                | Value                                  |
| ---------------------- | -------------------------------------- |
| Transport              | Remote MCP over HTTP                   |
| Server URL             | `https://mcp.deepidv.com/v1/mcp`       |
| Auth                   | OAuth 2.0 authorization code with PKCE |
| Local runtime required | No                                     |

## Installation Procedure

1. Add a new remote MCP server in the user's client.
2. Use `https://mcp.deepidv.com/v1/mcp` as the exact server URL.
3. Do not use the bare host without the `/v1/mcp` path.
4. Enter the required OAuth credentials:
   - `client_id`: the user's DeepIDV user ID
   - `client_secret`: any active DeepIDV API key owned by that same user
5. Start the OAuth flow if the client prompts for authorization.
6. If the client supports browser-based OAuth discovery, let it complete the normal login and approval flow.
7. After installation, verify the connection by listing tools or by asking the assistant to list workflows or verification sessions.

## Required Credentials

These credentials are mandatory.

Use:

- `client_id`: the user's DeepIDV user ID
- `client_secret`: any active DeepIDV API key owned by that same user

Do not invent, rotate, or generate separate OAuth credentials. The hosted DeepIDV OAuth server derives MCP client access from the user's existing DeepIDV identity and API key.

## Prerequisites To Confirm

Before starting, confirm that the user has:

- a DeepIDV account
- an active DeepIDV user
- an active API key for that same user

## Validation

After the server is installed, verify with one of these actions:

- Ask the client to list available MCP tools.
- Ask the assistant to run `list_workflows`.
- Ask the assistant to run `list_verification_sessions`.

Installation is successful if the client can complete OAuth and the tool list or tool calls return normally.

## Expected Tool Groups

The installed server should expose tools in these groups:

- Verification sessions
- Workflows
- Bank statements and financial requests

## Troubleshooting

### `invalid_token` or `401 Unauthorized`

- Re-run the OAuth flow.
- Confirm the `client_id` is the DeepIDV user ID.
- Confirm the API key used as `client_secret` belongs to that same DeepIDV user.
- Confirm the DeepIDV user and organization are active.

### Redirect URI not registered

The user's MCP client may not be using a redirect URI allowed by the DeepIDV hosted OAuth server. Use a client with standard remote MCP OAuth support, or ask DeepIDV support for compatibility guidance.

### The client tries to install this as a local package

Stop and switch to a remote MCP installation flow. This repository folder documents a hosted server and is not meant to be started locally for normal end-user setup.

## Notes for Marketplace Installation

- Prefer the hosted URL over any local workaround.
- Prefer the browser OAuth flow when the client supports it.
- Always collect `client_id` and `client_secret` as part of setup.
