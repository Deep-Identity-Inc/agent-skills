<div align="center">
  <img src="https://www.deepidv.com/logos/deepidv-logo-white.png" alt="deepidv" width="220" />
</div>

# deepidv: AI-Powered Verification Engine

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Skill Standard](https://img.shields.io/badge/agent--skills-v1.0-green.svg)](https://github.com/anthropics/agent-skills-spec)
[![GDPR Compliant](https://img.shields.io/badge/GDPR-Compliant-0057b8)](https://deepidv.com)
[![SOC 2 Compliant](https://img.shields.io/badge/SOC_2-Compliant-0057b8)](https://deepidv.com)
[![CCPA Compliant](https://img.shields.io/badge/CCPA-Compliant-0057b8)](https://deepidv.com)

**Verify anyone, anywhere in seconds.** [deepidv](https://deepidv.com) is an AI-powered verification engine that replaces the fragmented stack of identity vendors with a single platform. ID verification, face liveness, deepfake detection, AML screening, background checks, and more, all from one API.

This repository makes those capabilities accessible to AI agents and brings agentic intelligence into the deepidv platform itself. Three workstreams define how.

## The Workstreams

### Verify Skill

Any compatible AI agent can load this skill from the repository and immediately call deepidv's verification and screening APIs with no separate integration required. Endpoint routing, authentication, and request formatting are all handled by the skill.

| Capability                  | What it does                                                                            |
| --------------------------- | --------------------------------------------------------------------------------------- |
| Face liveness               | Confirms a selfie came from a live person, not a photo or replay attack                 |
| Identity verification       | Matches a government-issued ID against a selfie and validates the document              |
| Deepfake detection          | Determines whether an image or video is AI-generated or synthetically manipulated       |
| Adverse media screening     | Searches global news and public records for negative risk signals tied to a person      |
| AML and sanctions screening | Checks a subject against PEP lists, sanctions databases, and financial crime watchlists |
| Combined verification       | Runs a complete verification and screening flow in a single API call                    |

Compatible with Claude Code, Codex, Cursor, Windsurf, and OpenCode. Full invocation guidance, endpoint routing, authentication instructions, and worked examples are in [skills/deepidv-verify/SKILL.md](skills/deepidv-verify/SKILL.md).

### MCP Server

The MCP server turns deepidv's platform operations into structured tools that AI agents and orchestration frameworks can call directly. Verification workflows, compliance cases, screening history, and platform administration are all reachable over the Model Context Protocol.

| Domain                     | What it covers                                                                                      |
| -------------------------- | --------------------------------------------------------------------------------------------------- |
| Verification management    | Retrieve, search, and rerun verifications; access supporting media                                  |
| Case management            | Create, update, escalate, and resolve compliance cases                                              |
| Screening and monitoring   | Run screening jobs, review history, manage watchlists, view the compliance dashboard                |
| Support and administration | Query the knowledge base, track usage, pull audit logs, manage integrations, submit support tickets |

Built on Node.js and TypeScript with OAuth 2.0 + PKCE authentication. Full architecture detail is in [docs/architecture.md](docs/architecture.md).

### deepAI Assistant Skill

The deepAI Assistant is a coding agent skill that activates in context when you're building a deepidv integration. Rather than bouncing between docs and your editor, you get SDK guidance, error explanations, webhook setup help, and compliance workflow advice right in your editor.

The assistant loads automatically when a coding agent detects deepidv SDK usage, API calls, webhook configuration, or KYC workflow implementation in the active codebase. It covers the Node.js and Python SDKs and all public API surfaces.

## Marketplace Distribution

The Verify skill is listed across the major agent skill directories and MCP marketplaces, including SkillsMP, SkillHub, Agent-Skills.md, MCP Market, Skills Directory, LobeHub Skills, Orthogonal, and Awesome MCP Servers.

If you maintain a skill directory and would like to list this skill, open an issue or reach out to [sales@deepidv.com](mailto:sales@deepidv.com).

## Contributing

Bug reports, corrections to reference documentation, and improvements to skill definitions are welcome. Open an issue to discuss before submitting a pull request for anything substantial.

## About deepidv

deepidv is a full-stack verification engine built to replace the fragmented stack of identity providers most teams are stuck with. It verifies identities, runs compliance screening, and monitors for fraud continuously. One platform, one API, one dashboard, one team.

Learn more at [deepidv.com](https://deepidv.com).

## License

[Apache License 2.0](LICENSE)
