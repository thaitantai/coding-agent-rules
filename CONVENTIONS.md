# AI Agent Native Adapter

This file is intentionally short. It is the native entrypoint for this coding agent.
Do not treat it as the full rulebook.

## Load Protocol
Before changing files:

1. Read `.ai/agent-core.md`.
2. Infer the task from user intent, likely touched files, and implementation risk.
3. Read `.ai/rules-index.md`.
4. Load only the matching rule modules from `.ai/rules/*.md`.
5. Read `.ai/reference-index.md` only when mature reference repositories would improve architecture or code-quality judgment.
6. If the task is ambiguous, inspect relevant files first, then select the smallest safe rule set.

## Hard Requirements
- Do not load every rule module by default.
- Do not edit generated native adapter files manually.
- Edit `.ai/agent-core.md`, `.ai/rules-index.md`, `.ai/reference-index.md`, or `.ai/rules/*.md`, then run `sync-rules.ps1`.
- Treat `.ai/reference-index.md` as advisory knowledge, not mandatory policy.
- If a rule was not loaded and later becomes relevant, load it before continuing.
