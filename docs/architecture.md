# deepidv Agent Skills & MCP Architecture

## Overview

This document describes the main components in this repository and how they fit together.

| Component                | What It Does                                                                                                                   | Distribution                                    |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------- |
| **deepidv Verify Skill** | Agent skill for face liveness, identity verification, deepfake detection, adverse media screening, and AML or sanctions checks | Public GitHub repository and skill marketplaces |
| **deepidv MCP Server**   | Model Context Protocol server for authenticated backoffice operations                                                          | Internal deployment                             |
| **deepAI Skill/API**     | Developer-assistant skill and chat API for SDK and integration guidance                                                        | Bundled with SDK and assistant integrations     |

## Repository Structure

```
agent-skills/
├── README.md
├── LICENSE
├── .well-known/
│   ├── ai-plugin.json          # OpenAI plugin manifest
│   └── claw-skills.json        # OpenClaw discovery manifest
├── skills/
│   ├── deepidv-verify/
│   │   ├── SKILL.md            # Verify skill definition
│   │   ├── agents/
│   │   │   └── openai.yaml     # Codex metadata
│   │   ├── scripts/
│   │   │   └── verify.sh       # CLI wrapper
│   │   ├── references/
│   │   │   ├── api-reference.md
│   │   │   ├── error-codes.md
│   │   │   └── rate-limits.md
│   │   └── assets/             # Branding assets
│   └── deepai-assistant/
│       ├── SKILL.md            # deepAI skill definition
│       └── references/
│           ├── sdk-guide.md
│           └── faq.md
├── mcp-server/                 # MCP server
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile
│   └── src/
│       ├── index.ts            # Server entrypoint
│       ├── tools/              # Tool definitions
│       ├── auth/               # OAuth / permissions
│       └── handlers/           # Request handlers
└── docs/
    ├── architecture.md         # This document
    └── marketplace-listing-checklist.md
```

## Verify Skill

The Verify skill exposes six API endpoints:

- `POST /v1/verify/liveness` — Face liveness detection
- `POST /v1/verify/identity` — Full KYC verification
- `POST /v1/verify/deepfake` — Deepfake detection
- `POST /v1/screen/adverse-media` — Adverse media screening
- `POST /v1/screen/aml` — AML/sanctions screening
- `POST /v1/verify/full` — Combined verification

See `skills/deepidv-verify/SKILL.md` for the complete skill definition.

## MCP Server

The MCP server runs at `mcp.deepidv.com` and provides more than 20 tools organized by domain:

- **Verification Management** (5 tools): get, list, search, media, rerun
- **Case Management** (5 tools): create, update, list, escalate, resolve
- **Screening & Monitoring** (4 tools): run, history, watchlist, dashboard
- **Support & Admin** (6 tools): knowledge base, usage, audit, report, integration, support ticket

**Tech stack:** Node.js + TypeScript, ECS Fargate, OAuth 2.0 + PKCE, MCP over SSE.

## deepAI Skill and API

- **SKILL.md**: Developer-assistant skill loaded by coding agents
- **REST API**: `POST /v1/ai/chat` for programmatic integration guidance
