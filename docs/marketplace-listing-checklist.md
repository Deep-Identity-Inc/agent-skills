# Marketplace Listing Checklist

Use this checklist when preparing marketplace submissions for the deepidv Verify skill.

## Before Submission

- [x] Repository is public.
- [x] Verify skill lives under `skills/deepidv-verify/`.
- [x] `SKILL.md` includes YAML frontmatter with `name` and `description`.
- [x] Structured agent metadata exists in `skills/deepidv-verify/agents/openai.yaml`.
- [x] Reference docs exist for API contracts, errors, and rate limits.
- [x] CLI wrapper exists in `skills/deepidv-verify/scripts/verify.sh`.
- [x] Marketplace branding assets exist in `skills/deepidv-verify/assets/`.
- [ ] Sandbox demo flow has been manually exercised with a sandbox key.

## Listing Tracker

| Marketplace         | Submission Model    | Status                 | Required Inputs                                           | Tracking Notes                                                           |
| ------------------- | ------------------- | ---------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------ |
| SkillsMP            | Auto-indexed        | Waiting on public repo | Public GitHub repo and discoverable skill under `skills/` | Verify listing after the next index cycle                                |
| SkillHub            | Auto-indexed        | Waiting on public repo | Public GitHub repo and high-quality `SKILL.md`            | Review the score and listing copy after the first scan                   |
| Agent-Skills.md     | Manual submission   | Ready to submit        | Repo URL and path to `skills/`                            | Frontmatter requirement satisfied                                        |
| MCP Market          | Manual submission   | Ready to submit        | Repo URL, install instructions, public description        | Include Verify skill summary and sandbox support                         |
| Skills Directory    | Manual submission   | Ready to submit        | Repo URL and security-safe documentation                  | Confirm docs do not encourage unsafe secret handling                     |
| LobeHub Skills      | Manual submission   | Ready to submit        | Skill metadata, description, branding assets              | Use assets from `skills/deepidv-verify/assets/`                          |
| Orthogonal          | Partnership request | Ready to contact       | SKILL URL, pricing detail, sandbox and live environments  | Provide demo path and environment guidance                               |
| Awesome MCP Servers | Pull request        | Ready to submit        | Repo URL, category, description                           | Keep the listing focused on the Verify skill and its public API coverage |

## Submission Notes

### SkillsMP

- Confirm the repo is public.
- Confirm `skills/deepidv-verify/SKILL.md` remains discoverable at the default path.
- Record the public listing URL after indexing.

### SkillHub

- Confirm the repo is public.
- Re-check the skill body for concise routing guidance and realistic examples before the first scrape.
- Record the score and any evaluator feedback.

### Agent-Skills.md

- Submit the public repository URL.
- Point reviewers to `skills/deepidv-verify/`.
- Include that the package supports sandbox and production without code changes.

### MCP Market

- Submit the repository URL.
- Use the README plus `skills/deepidv-verify/SKILL.md` for product description.
- Keep the listing centered on the Verify skill, its six endpoints, and sandbox support.

### Skills Directory

- Highlight API-key auth via environment variable or local credential file.
- Confirm the docs avoid committing or pasting secrets into source-controlled files.

### LobeHub Skills

- Upload or reference the brand assets from `skills/deepidv-verify/assets/`.
- Reuse the short description from the structured metadata file.

### Orthogonal

- Share the public repo URL.
- Include environment guidance, pricing, and a sandbox demo path.
- Note the six supported public endpoints.

### Awesome MCP Servers

- Open a pull request against their repo with a concise description.
- Describe the Verify skill clearly and avoid internal planning terminology.

## Evidence to Capture

- Marketplace listing URL or submission confirmation.
- Submission date.
- Reviewer feedback or issues.
- Follow-up owner.
