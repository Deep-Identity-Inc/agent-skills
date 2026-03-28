# deepidv Agent Skills and MCP Server

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Skill Standard](https://img.shields.io/badge/agent--skills-v1.0-green.svg)](https://github.com/anthropics/agent-skills-spec)

This repository contains deepidv's agent-facing integrations.

The deepidv Verify skill gives AI agents direct access to face liveness, identity verification, deepfake detection, adverse media screening, AML and sanctions screening, and combined verification through the deepidv API.

## deepidv Verify Skill

Location: `skills/deepidv-verify/`

Public capabilities:

- Face liveness
- Identity verification
- Deepfake detection
- Adverse media screening
- AML and sanctions screening
- Combined verification

Key files:

| Artifact                                            | Purpose                                                   |
| --------------------------------------------------- | --------------------------------------------------------- |
| `skills/deepidv-verify/SKILL.md`                    | Canonical public skill definition and invocation guidance |
| `skills/deepidv-verify/agents/openai.yaml`          | Structured metadata for agent ecosystems                  |
| `skills/deepidv-verify/references/api-reference.md` | Detailed endpoint request and response contracts          |
| `skills/deepidv-verify/references/error-codes.md`   | Public error catalog with operator actions                |
| `skills/deepidv-verify/references/rate-limits.md`   | Published rate-limit and retry guidance                   |
| `skills/deepidv-verify/scripts/verify.sh`           | CLI wrapper for manual testing and demos                  |
| `skills/deepidv-verify/assets/`                     | Marketplace branding assets                               |

## Verify Skill Quickstart

Authentication:

- Primary source: `DEEPIDV_API_KEY`
- Fallback files: `.deepidv/credentials` in the project root or `~/.deepidv/credentials`
- Auth header: `X-DEEPIDV-KEY`

Environment selection:

- Production base URL: `https://api.deepidv.com/v1`
- Sandbox base URL: `https://sandbox.api.deepidv.com/v1`
- Use sandbox keys for testing and live keys for production

Example setup:

```bash
export DEEPIDV_API_KEY="sk_test_your_key"
export DEEPIDV_ENV="sandbox"
```

Example manual request:

```bash
./skills/deepidv-verify/scripts/verify.sh liveness request.json
```

See the public skill definition for endpoint-routing guidance:

- `skills/deepidv-verify/SKILL.md`
- `skills/deepidv-verify/references/api-reference.md`
- `skills/deepidv-verify/references/error-codes.md`
- `skills/deepidv-verify/references/rate-limits.md`

## Repository Contents

| Component                  | Purpose                                                           |
| -------------------------- | ----------------------------------------------------------------- |
| `mcp-server/`              | MCP server for backoffice workflows                               |
| `skills/deepai-assistant/` | Developer-assistant skill for deepidv SDK and integration support |
| `docs/`                    | Architecture and marketplace publication tracking                 |

## Marketplace Distribution

The Verify skill can be listed in the following directories and marketplaces:

- SkillsMP
- SkillHub
- Agent-Skills.md
- MCP Market
- Skills Directory
- LobeHub Skills
- Orthogonal
- Awesome MCP Servers

Track submission status in `docs/marketplace-listing-checklist.md`.

## License

[Apache License 2.0](LICENSE)
