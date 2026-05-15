# Project File Structure Standards

## Context
- Applies whenever creating, moving, or renaming files and directories.
- These conventions keep the codebase navigable regardless of team size.

## Universal Rules (All Project Types)
- Source code lives in `src/` — never in the root.
- Tests mirror the `src/` structure inside `tests/` (or co-located as `*.test.*`).
- Configuration files live at the root: `.env`, `tsconfig.json`, `pyproject.toml`, etc.
- Generated files go in `dist/`, `build/`, or `.cache/` — all gitignored.
- Documentation lives in `docs/`.
- Scripts (migration, seeding, automation) live in `scripts/`.
- Never mix concerns in a single directory: UI components do not live next to DB schemas.

## Naming Conventions
| Type | Convention | Example |
|---|---|---|
| Directories | `kebab-case` | `user-profile/` |
| React/Vue components | `PascalCase` | `UserCard.tsx` |
| Utilities / helpers | `camelCase` | `formatDate.ts` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Test files | `*.test.*` or `*.spec.*` | `auth.service.test.ts` |
| Type/Interface files | `*.types.ts` | `user.types.ts` |
| Environment files | `.env`, `.env.local`, `.env.production` | Never commit `.env` |

---

## 📁 Node.js / TypeScript (Backend API)
```
src/
├── config/          # App configuration, env parsing (zod schemas)
├── modules/         # Feature modules (see module structure below)
│   └── users/
│       ├── users.controller.ts
│       ├── users.service.ts
│       ├── users.repository.ts
│       ├── users.types.ts
│       └── users.module.ts
├── shared/
│   ├── middleware/  # Auth, logging, rate-limit
│   ├── guards/      # Authorization guards
│   ├── decorators/  # Custom decorators
│   ├── filters/     # Error/exception filters
│   └── utils/       # Pure utility functions
├── database/
│   ├── migrations/
│   ├── seeders/
│   └── schema/      # Table/model definitions
└── main.ts          # Entry point only — no logic here

tests/
├── unit/            # Mirror src/modules structure
├── integration/     # Cross-module tests
└── e2e/             # End-to-end flows
```

**Layer rules (strict):**
- `controller` → calls `service` only. No DB access.
- `service` → business logic. Calls `repository`. Never calls another controller.
- `repository` → DB access only. No business logic.
- `shared/utils` → Pure functions only. No side effects, no DB, no HTTP.

---

## 📁 Next.js / React (Frontend / Fullstack)
```
src/
├── app/             # Next.js App Router — route segments only
│   ├── (auth)/      # Route groups (no URL impact)
│   ├── api/         # API Routes / Route Handlers
│   └── layout.tsx
├── components/
│   ├── ui/          # Primitive/generic components (Button, Modal, Input)
│   └── features/    # Feature-specific composite components
│       └── user-profile/
├── hooks/           # Custom React hooks (use*.ts)
├── lib/             # Server actions, API clients, external SDK wrappers
├── store/           # Global state (Zustand, Redux, Jotai)
├── styles/          # Global CSS, Tailwind config extensions
└── types/           # Shared TypeScript types

public/              # Static assets served as-is
```

**Component rules:**
- `ui/` components are dumb — props only, no data fetching, no store access.
- `features/` components may access store and call server actions.
- Hooks prefixed with `use`, e.g., `useAuth`, `useCart`.
- Server Components by default. Add `"use client"` only when necessary.

---

## 📁 Python (FastAPI / Django / Flask)
```
src/
├── api/
│   └── v1/
│       ├── routes/       # Route definitions (thin layer)
│       └── dependencies/ # FastAPI deps / middleware
├── core/
│   ├── config.py         # Settings via pydantic-settings
│   ├── security.py       # Auth/crypto helpers
│   └── exceptions.py     # Custom exception classes
├── models/               # SQLAlchemy / Django ORM models
├── schemas/              # Pydantic request/response schemas
├── services/             # Business logic
├── repositories/         # DB queries
└── main.py               # App factory / entry point

tests/
├── unit/
├── integration/
└── conftest.py           # Shared fixtures
```

---

## 📁 Monorepo (Turborepo / Nx)
```
apps/
├── web/             # Next.js frontend
├── api/             # Node.js backend
└── mobile/          # React Native (if applicable)

packages/
├── ui/              # Shared component library
├── config/          # Shared ESLint, TypeScript, etc.
├── types/           # Shared TypeScript types
└── utils/           # Shared utility functions

scripts/             # Workspace-level automation
turbo.json
package.json         # Root workspace config
```

**Monorepo rules:**
- Cross-package imports must go through the package's public `index.ts`.
- Never import directly from another app's `src/`.
- Shared code → `packages/`. App-specific code → stays in `apps/`.
