---
name: deepai-assistant
description: >-
  deepidv integration assistant. Use when working with the deepidv SDK,
  API, or platform and need help with implementation, error resolution,
  webhook configuration, compliance workflows, or best practices.
  Triggers on: deepidv SDK, deepidv API, deepidv integration, deepidv error,
  deepidv webhook, verification workflow, KYC implementation.
license: Apache-2.0
compatibility: claude-code, codex, cursor, opencode, windsurf
metadata:
  author: deepidv
  version: 1.0.0
  category: developer-tools
  tags: [deepidv, sdk, api, support, integration, compliance]
---

# deepAI — deepidv Integration Assistant

Your AI assistant for building with the deepidv SDK, API, and platform.

## When To Use This Skill

Use this skill when you are:

- Integrating the deepidv SDK into your application
- Debugging deepidv API errors or unexpected responses
- Configuring webhooks for verification events
- Implementing KYC/compliance workflows
- Looking for best practices on identity verification flows

## SDK Installation & Setup

### Node.js

```bash
npm install @deepidv/sdk
```

```javascript
import { DeepIDV } from "@deepidv/sdk";

const client = new DeepIDV({
  apiKey: process.env.DEEPIDV_API_KEY,
});
```

### Python

```bash
pip install deepidv
```

```python
from deepidv import DeepIDV

client = DeepIDV(api_key=os.environ["DEEPIDV_API_KEY"])
```

## Authentication Patterns

<!-- TODO: Full authentication patterns (API key, OAuth client credentials, webhook HMAC-SHA256) -->

## Verification Flow Implementation

<!-- TODO: Step-by-step code patterns for liveness, identity, deepfake, screening -->

## Webhook Integration

<!-- TODO: Event types, payload schemas, retry logic, signature validation -->

## Error Resolution Guide

<!-- TODO: Common errors mapped to solutions -->

## Compliance Configuration

<!-- TODO: Jurisdiction-specific rules, FINTRAC/FinCEN reporting, data retention -->

## SDK Reference (Condensed)

<!-- TODO: Key methods, types, interfaces -->

## FAQ / Troubleshooting

<!-- TODO: Top 30 integration questions -->
