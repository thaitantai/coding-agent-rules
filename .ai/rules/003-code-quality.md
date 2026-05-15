# Code Quality & Patterns

## Context
- Applies to all code written or modified across all languages.
- Goal: code that is correct, readable, and maintainable by any team member.

## Functions & Methods
- One function = one responsibility. If it does two things, split it.
- Maximum function length: ~40 lines. If longer, extract sub-functions.
- Maximum nesting depth: 3 levels. Use early returns to flatten.
- Name functions with verbs: `getUser`, `validateEmail`, `sendNotification`.
- Pure functions preferred — same input always produces same output, no side effects.
- Avoid boolean parameters: `sendEmail(user, true)` → use options object or separate functions.

```ts
// ❌ Bad
function process(data, isAdmin, sendEmail) { ... }

// ✅ Good
function processUserData(data: UserData, options: ProcessOptions) { ... }
```

## Variables & Naming
- Names must reveal intent. No single-letter variables except loop counters.
- Use `isX`, `hasX`, `canX` for booleans: `isLoading`, `hasPermission`, `canDelete`.
- Constants at module level in SCREAMING_SNAKE_CASE.
- Avoid abbreviations unless universally understood (e.g., `id`, `url`, `http`).
- Prefer `const` over `let`. Never use `var`.

```ts
// ❌ Bad
const d = new Date();
const x = users.filter(u => u.a === true);

// ✅ Good
const createdAt = new Date();
const activeUsers = users.filter(user => user.isActive);
```

## Error Handling
- Never swallow errors silently. At minimum, log them.
- Catch errors at the boundary (controller/route handler), not deep in business logic.
- Use custom error classes with meaningful names and HTTP status codes.
- Always validate external input (API requests, env vars, file contents).
- Use Result types or explicit error returns instead of throwing in service layers.

```ts
// ❌ Bad
try {
  const user = await getUser(id);
} catch (e) {
  // silence
}

// ✅ Good
try {
  const user = await getUser(id);
} catch (error) {
  logger.error({ error, userId: id }, 'Failed to fetch user');
  throw new UserNotFoundError(id);
}
```

## Async / Concurrency
- Always `await` Promises — never fire-and-forget unless intentional (and commented).
- Use `Promise.all()` for independent parallel operations, not sequential awaits.
- Handle Promise rejections — unhandled rejections crash Node.js processes.
- Add timeouts to all network calls.

```ts
// ❌ Bad — sequential when parallel is possible
const user = await getUser(id);
const permissions = await getPermissions(id);

// ✅ Good
const [user, permissions] = await Promise.all([
  getUser(id),
  getPermissions(id),
]);
```

## Comments & Documentation
- Comment WHY, not WHAT. The code explains what; comments explain the reasoning.
- Keep comments up-to-date. Stale comments are worse than no comments.
- JSDoc / docstrings for all public APIs, services, and shared utilities.
- Mark technical debt explicitly: `// TODO(username): ...` or `// FIXME: ...`.

```ts
// ❌ Bad comment
// increment i
i++;

// ✅ Good comment
// Retry limit is 3 to match the SLA agreement with the payment provider.
const MAX_RETRIES = 3;
```

## Imports & Dependencies
- Group imports: (1) Node built-ins → (2) External packages → (3) Internal modules.
- Use absolute imports / path aliases (`~/`, `@/`) — never relative `../../../`.
- No circular dependencies. If A imports B and B imports A, extract a shared module C.
- Tree-shake friendly: import named exports, not entire libraries.

```ts
// ❌ Bad
import * as _ from 'lodash';
import { something } from '../../../shared/utils';

// ✅ Good
import { debounce } from 'lodash';
import { formatDate } from '~/shared/utils/date';
```

## State Management
- Keep state as local as possible — lift only when necessary.
- Server state (API data) → React Query / SWR / Tanstack Query.
- Client UI state → local component state.
- Global app state → Zustand / Redux (only when truly global).
- Never store derived data in state — compute it from existing state.

## Magic Numbers & Strings
- Never use magic numbers or strings inline. Always extract to named constants.

```ts
// ❌ Bad
if (user.role === 2) { ... }
setTimeout(fn, 86400000);

// ✅ Good
const ROLE_ADMIN = 2;
const ONE_DAY_MS = 24 * 60 * 60 * 1000;
```
