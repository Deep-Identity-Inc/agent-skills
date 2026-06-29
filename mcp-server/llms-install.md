# DeepIDV MCP Installation Guide for Agents

Use this file when you are installing the DeepIDV MCP server for a user from
this repository.

## Goal

Connect the user to the hosted DeepIDV MCP server at
`https://mcp.deepidv.com/v1/mcp`.

Do not build or run a local server from this repository for normal setup. This
MCP server is already hosted by DeepIDV.

## Server Details

| Setting                     | Value                                                           |
| --------------------------- | --------------------------------------------------------------- |
| Transport                   | Remote MCP over HTTP                                            |
| Server URL                  | `https://mcp.deepidv.com/v1/mcp`                                |
| Server manifest             | `https://mcp.deepidv.com/mcp.json`                              |
| Protected resource metadata | `https://mcp.deepidv.com/.well-known/oauth-protected-resource`  |
| OAuth client ID             | `deepidv`                                                       |
| Auth                        | OAuth 2.0 authorization code with PKCE                          |
| Local runtime required      | No                                                              |

## Installation Procedure

1. Add a new remote MCP server in the user's client.
2. Use `https://mcp.deepidv.com/v1/mcp` as the exact server URL.
3. Do not use the bare host without the `/v1/mcp` path.
4. If the client asks for `client_id`, enter `deepidv`.
5. Do not enter a `client_secret`.
6. Start the OAuth flow if the client prompts for authorization.
7. Complete the browser-based deepidv sign-in flow with email, password, and
   MFA if required.
8. After installation, verify the connection by listing tools or by asking the
   assistant to list workflows or verification sessions.

## Authentication Model

The current hosted MCP flow uses a shared public OAuth client:

- `client_id`: `deepidv`
- `client_secret`: not used
- user sign-in: deepidv email and password
- MFA: required when enabled on the user's account

If the MCP client requires a static `client_secret` for remote MCP setup, treat
that client as incompatible with DeepIDV's current hosted OAuth model.

## Prerequisites To Confirm

Before starting, confirm that the user has:

- a DeepIDV account
- an active DeepIDV user
- their deepidv email and password
- MFA access if their account requires it

## Validation

After the server is installed, verify with one of these actions:

- Ask the client to list available MCP tools.
- Ask the assistant to run `list_workflows`.
- Ask the assistant to run `list_verification_sessions`.
- Ask the assistant to run `run_pep_sanctions_check`.

Installation is successful if the client can complete OAuth and the tool list
or tool calls return normally.

## Expected Tool Groups

The installed server should expose tools in these groups:

- Applicants
- Verification sessions
- Workflows
- Bank statements and financial requests
- Silent screening

## Troubleshooting

### `invalid_token` or `401 Unauthorized`

- Re-run the OAuth flow.
- Confirm the server URL is `https://mcp.deepidv.com/v1/mcp`.
- If the client asked for `client_id`, confirm it was set to `deepidv`.
- Confirm the DeepIDV user and organization are active.

### The client asks for a `client_secret`

DeepIDV's current hosted MCP flow does not use a `client_secret`. Do not tell
the user to enter an API key here. Use a client that supports public OAuth and
PKCE for remote MCP servers.

### Redirect URI not registered

The user's MCP client may not be using a redirect URI allowed by the DeepIDV
hosted OAuth server. Use a client with standard remote MCP OAuth support, or
ask DeepIDV support for compatibility guidance.

### The client tries to install this as a local package

Stop and switch to a remote MCP installation flow. This repository folder
documents a hosted server and is not meant to be started locally for normal
end-user setup.

## Notes for Marketplace Installation

- Prefer the hosted URL over any local workaround.
- Prefer the browser OAuth flow when the client supports it.
- Use `deepidv` only if the client explicitly asks for `client_id`.
- Never tell the user to generate or paste a `client_secret` for this flow.
