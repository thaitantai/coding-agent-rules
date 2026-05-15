# Reference Index

## Purpose
This file lists curated external repositories that can improve architectural judgment.
Use them as reference material, not as mandatory templates.

## Usage Protocol
- Consult references only after loading the relevant local rules from `.ai/rules-index.md`.
- Use references when the task needs architectural judgment, code organization decisions, or best-practice examples beyond the local rule text.
- Prefer existing project patterns, installed dependencies, and local conventions over external examples.
- Do not copy large code blocks or project structures verbatim.
- Do not introduce dependencies just because a reference repo uses them.
- If network or RAG access is unavailable, continue with local rules and the current codebase.

## Curated References
| Reference | URL | Use when |
|---|---|---|
| Bulletproof React | `https://github.com/alan2207/bulletproof-react` | Designing or refactoring production React/TypeScript apps, feature-based structure, API layer, state management, testing, security, performance, and deployment boundaries. |
| Node.js Best Practices | `https://github.com/goldbergyoni/nodebestpractices` | Designing Node.js backend architecture, layered components, configuration, error handling, logging, testing, security, API boundaries, and deployment readiness. |
| Clean Code JavaScript | `https://github.com/ryanmcdermott/clean-code-javascript` | Improving JavaScript/TypeScript readability, naming, function design, data structures, SOLID thinking, async/error handling, tests, formatting, and comments. |

## Reference Selection
| Task shape | Suggested references |
|---|---|
| React architecture, frontend modules, feature folders, API client boundaries | Bulletproof React |
| Node.js backend structure, services/controllers/data access, operational robustness | Node.js Best Practices |
| Naming, function extraction, readability, JS/TS refactoring | Clean Code JavaScript |
| Fullstack TypeScript feature touching frontend and backend | Bulletproof React + Node.js Best Practices + Clean Code JavaScript |

## Guardrails
- References help answer "what does good look like?" They do not override `.ai/agent-core.md`, `.ai/rules/*.md`, or the user's explicit request.
- Import the principle, not the entire architecture.
- When a reference conflicts with the existing project style, follow the project style unless the task explicitly asks for a refactor.
- When citing a reference in reasoning, name the principle used, not a vague appeal to authority.
