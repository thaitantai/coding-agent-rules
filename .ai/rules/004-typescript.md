# TypeScript Standards

## Context
- Applies to all `.ts` and `.tsx` files.
- Goal: leverage the type system fully to catch bugs at compile time, not runtime.

## Core Rules
- Strict mode always on: `"strict": true` in `tsconfig.json`. No exceptions.
- Never use `any`. If you must, use `unknown` and narrow with type guards.
- Never use type assertions (`as SomeType`) unless you can prove correctness. Document why.
- Enable `noUncheckedIndexedAccess` — array/object access can be undefined.
- Types for data shapes, Interfaces for contracts (classes/objects that are extended).

## Type Definitions
- Co-locate types with the code that uses them. Shared types go in `*.types.ts`.
- Prefer `type` for unions, intersections, and aliases. Prefer `interface` for object shapes.
- Use `readonly` for props and data that should not be mutated.
- Use `as const` for fixed literal values.
- Export only what is needed — keep types private by default.

```ts
// ❌ Bad
const config = { theme: 'dark', lang: 'en' };
function process(data: any) { ... }

// ✅ Good
const CONFIG = { theme: 'dark', lang: 'en' } as const;
type Config = typeof CONFIG;
function process(data: unknown): ProcessedData {
  if (!isValidData(data)) throw new InvalidDataError();
  ...
}
```

## Generics
- Use descriptive generic names, not single letters unless conventional (`T`, `K`, `V`).
- Constrain generics when possible: `<T extends User>` instead of bare `<T>`.
- Don't over-generalize — make generic only when it solves a real reuse problem.

```ts
// ❌ Bad
function getFirst<T>(arr: T[]): T { ... }

// ✅ Good — constrained and descriptive
function getFirstActive<TEntity extends { isActive: boolean }>(
  entities: TEntity[]
): TEntity | undefined {
  return entities.find(e => e.isActive);
}
```

## Nullability
- Use optional chaining `?.` and nullish coalescing `??` instead of manual null checks.
- Never use `!` (non-null assertion) in production code — it defeats type safety.
- Explicitly model optional values: `string | null` (intentionally null) vs `string | undefined` (optional).

```ts
// ❌ Bad
const name = user!.profile!.name;

// ✅ Good
const name = user?.profile?.name ?? 'Anonymous';
```

## Enums & Unions
- Prefer `const` object + union type over `enum` (better tree-shaking, JS interop).

```ts
// ❌ Bad (enum)
enum UserRole { Admin, Editor, Viewer }

// ✅ Good (const union)
const USER_ROLE = {
  ADMIN: 'admin',
  EDITOR: 'editor',
  VIEWER: 'viewer',
} as const;
type UserRole = typeof USER_ROLE[keyof typeof USER_ROLE];
```

## Zod / Validation
- Validate all external data (API input, env vars, localStorage) with Zod or similar.
- Derive TypeScript types from Zod schemas — single source of truth.
- Never trust `req.body` or external JSON without parsing.

```ts
// ✅ Good
const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['admin', 'editor', 'viewer']),
});

type CreateUserInput = z.infer<typeof CreateUserSchema>;

// In handler:
const input = CreateUserSchema.parse(req.body); // throws if invalid
```

## Path Aliases
- Always configure and use path aliases. Never use deep relative paths.

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "~/*": ["src/*"],
      "@shared/*": ["src/shared/*"]
    }
  }
}
```

## Return Types
- Explicitly annotate return types for all public functions and class methods.
- Use `Promise<void>` explicitly for async functions that return nothing.
- Use discriminated unions for functions that return success or error.

```ts
// ✅ Good — explicit, predictable
async function createUser(input: CreateUserInput): Promise<User> { ... }

type Result<T> =
  | { success: true; data: T }
  | { success: false; error: string };

async function findUser(id: string): Promise<Result<User>> { ... }
```
