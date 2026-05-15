# Testing Standards

## Context
- Applies to all test files (`*.test.*`, `*.spec.*`).
- Goal: a test suite that catches real bugs, runs fast, and stays maintainable.

## What to Test
- **Unit tests**: Pure functions, service layer business logic, utility functions.
- **Integration tests**: Module interactions, DB queries (with test DB), API endpoints.
- **E2E tests**: Critical user journeys only (login, checkout, core workflows).
- Do NOT test: framework internals, third-party library behavior, trivial getters/setters.

## Coverage Targets
- Business logic (services): 80%+ coverage.
- Utility functions: 100% coverage.
- UI components: test behavior, not implementation.
- E2E: cover happy path + 1-2 critical failure paths per feature.

## Test Structure — AAA Pattern
Every test follows Arrange → Act → Assert:

```ts
describe('UserService', () => {
  describe('createUser', () => {
    it('should hash password before saving', async () => {
      // Arrange
      const input = { email: 'test@example.com', password: 'plaintext' };
      const mockRepo = { save: vi.fn().mockResolvedValue({ id: '1', ...input }) };
      const service = new UserService(mockRepo);

      // Act
      await service.createUser(input);

      // Assert
      expect(mockRepo.save).toHaveBeenCalledWith(
        expect.objectContaining({
          password: expect.not.stringContaining('plaintext'),
        })
      );
    });
  });
});
```

## Naming Rules
- Test files: `[module-name].test.ts` co-located, or `tests/unit/[module-name].test.ts`.
- `describe` block: the module or class name.
- `it` / `test` block: starts with `should` — describes behavior, not implementation.

```ts
// ❌ Bad names
it('test createUser', () => { ... });
it('createUser works', () => { ... });

// ✅ Good names
it('should return 404 when user does not exist', () => { ... });
it('should throw ValidationError when email is invalid', () => { ... });
```

## Mocking Rules
- Mock at the boundary: external services, DB, file system, clock, randomness.
- Never mock what you own (your own services/utilities) in unit tests — test the real thing.
- Use `vi.fn()` / `jest.fn()` for function mocks. Never mock entire modules unless necessary.
- Reset mocks between tests: `beforeEach(() => { vi.clearAllMocks(); })`.
- Use factories / builders for test data — never hardcode raw objects everywhere.

```ts
// ✅ Good — test data factory
const makeUser = (overrides: Partial<User> = {}): User => ({
  id: 'user-123',
  email: 'test@example.com',
  isActive: true,
  createdAt: new Date('2024-01-01'),
  ...overrides,
});

// Usage
const bannedUser = makeUser({ isActive: false });
```

## Async Tests
- Always `await` async operations. Never leave floating promises in tests.
- Use `expect.assertions(n)` for async tests to catch silent test passes.

```ts
it('should reject with AuthError on invalid token', async () => {
  expect.assertions(1);
  await expect(authService.verify('bad-token')).rejects.toThrow(AuthError);
});
```

## API / Integration Tests
- Use a real test database (not mocked) for integration tests.
- Seed and teardown data per test or per suite — tests must be independent.
- Test the full request/response cycle including headers, status codes, body shape.

```ts
it('POST /users should return 201 with created user', async () => {
  const res = await request(app)
    .post('/users')
    .send({ email: 'new@example.com', name: 'Alice' });

  expect(res.status).toBe(201);
  expect(res.body).toMatchObject({
    id: expect.any(String),
    email: 'new@example.com',
  });
  expect(res.body).not.toHaveProperty('password');
});
```

## What Not to Do
- Never skip tests with `.skip` without a comment explaining why and a ticket reference.
- Never use `setTimeout` in tests — mock the clock with `vi.useFakeTimers()`.
- Never assert on internal implementation details (private methods, internal state).
- Never let tests share state — each test must be able to run in isolation.
