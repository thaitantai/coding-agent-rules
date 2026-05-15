# Rules Index

## How To Use This Index
Use this file after reading `.ai/agent-core.md`.
Select rules from intent, touched files, and risk. Do not load every rule by default.

## Baseline
| Situation | Load |
|---|---|
| Every task | `.ai/rules/001-general.md` |
| Any code edit | `.ai/rules/003-code-quality.md` |
| Ambiguous code work | Inspect likely files first, then load language/framework and risk rules |

## Intent And File Triggers
| Trigger | Load |
|---|---|
| Creating, moving, renaming, or reorganizing files/directories | `.ai/rules/002-file-structure.md` |
| Editing `*.ts`, `*.tsx`, `tsconfig.json`, TypeScript config, React/Node TypeScript code | `.ai/rules/004-typescript.md` |
| Editing `*.test.*`, `*.spec.*`, test fixtures, mocks, test config, or user asks for tests | `.ai/rules/005-testing.md` |
| Commit, branch, PR, release, changelog, gitignore, or GitHub workflow conventions | `.ai/rules/006-git.md` |
| Auth, authorization, sessions, JWT, cookies, passwords, secrets, env vars, user input, uploads, payments, PII, or access control | `.ai/rules/007-security.md` |
| Database queries, pagination, caching, large lists, slow rendering, bundle size, background jobs, or profiling | `.ai/rules/008-performance.md` |
| REST endpoints, GraphQL, route handlers, controllers, request/response schemas, OpenAPI, API versioning | `.ai/rules/009-api-design.md` |
| `.env*`, Dockerfile, docker-compose, CI/CD, deployment, migrations, health checks, observability | `.ai/rules/010-environment.md` |

## Common Human-Style Classifications
| Task shape | Suggested rule set |
|---|---|
| "Fix login/register/session" | `001-general`, `003-code-quality`, language rule, `005-testing`, `007-security`, `009-api-design` if an endpoint changes |
| "Add or change an API endpoint" | `001-general`, `003-code-quality`, language rule, `005-testing`, `007-security`, `009-api-design` |
| "Optimize list/search/query performance" | `001-general`, `003-code-quality`, language rule, `005-testing`, `008-performance`, `009-api-design` if response shape changes |
| "Change env/Docker/CI/deploy" | `001-general`, `007-security`, `010-environment` |
| "Move files or create project structure" | `001-general`, `002-file-structure` |
| "Write or fix tests" | `001-general`, `003-code-quality`, `005-testing`, language rule when applicable |
| "Prepare commit/PR/release" | `001-general`, `006-git` |
| "Docs-only change" | `001-general`; add domain rules only if the docs prescribe implementation behavior |

## Safety Fallback
If a task looks simple but touches security, API contracts, data shape, persistence, deployment, or tests, load the matching risk rule even when the user did not mention that domain.

## Reference Escalation
After selecting local rules, read `.ai/reference-index.md` when the task needs examples from mature repositories.

| Need | Consult |
|---|---|
| React/TypeScript app architecture, feature folders, API layer, state boundaries | Bulletproof React |
| Node.js backend architecture, layered components, error handling, operational practices | Node.js Best Practices |
| JavaScript/TypeScript readability, naming, function design, refactoring judgment | Clean Code JavaScript |

References are advisory. They do not override local rules, current codebase conventions, or the user's explicit request.
