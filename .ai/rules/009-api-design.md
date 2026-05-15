# API Design Standards

## Context
- Applies to all REST API and GraphQL endpoint design.
- Goal: APIs that are predictable, versioned, and developer-friendly.

## REST Conventions
- Use nouns for resources, not verbs: `/users` not `/getUsers`.
- Use HTTP methods semantically:
  - `GET` → read (idempotent, no side effects)
  - `POST` → create
  - `PUT` → full replace
  - `PATCH` → partial update
  - `DELETE` → remove
- Nested resources: max 2 levels deep. `/users/:id/orders` ✅ — `/users/:id/orders/:id/items/:id` ❌
- Use plural nouns: `/users`, `/orders`, `/products`.

## URL Structure
```
GET    /api/v1/users           → list users (paginated)
POST   /api/v1/users           → create user
GET    /api/v1/users/:id       → get one user
PATCH  /api/v1/users/:id       → update user (partial)
DELETE /api/v1/users/:id       → delete user

GET    /api/v1/users/:id/orders → list orders for user
```

## Versioning
- Always version your API from day one: `/api/v1/`.
- Version in URL path (not header) — easier to test and share.
- Never break existing endpoints without a new version.
- Deprecate with `Deprecation` and `Sunset` response headers before removing.

## Request & Response Shape
- Request body: `camelCase` JSON. Validate with schema (Zod, Joi, Pydantic).
- Response body: always wrap in consistent envelope:

```json
// Success
{
  "data": { "id": "123", "email": "user@example.com" },
  "meta": { "requestId": "abc-456" }
}

// List
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "nextCursor": "eyJpZCI6..."
  }
}

// Error
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is invalid",
    "fields": { "email": "Must be a valid email address" }
  },
  "meta": { "requestId": "abc-456" }
}
```

## HTTP Status Codes
```
200 OK              → successful GET, PATCH, DELETE
201 Created         → successful POST (include Location header)
204 No Content      → successful DELETE with no body
400 Bad Request     → validation error, malformed request
401 Unauthorized    → not authenticated
403 Forbidden       → authenticated but not authorized
404 Not Found       → resource does not exist
409 Conflict        → duplicate resource, optimistic lock failure
422 Unprocessable   → business rule violation
429 Too Many Requests → rate limited
500 Internal Error  → unexpected server error (never expose details)
```

## Error Design
- Use machine-readable error codes alongside human messages.
- Include a `requestId` in every error for log correlation.
- Validation errors: return ALL field errors at once, not one at a time.
- Never return 200 with an error in the body.

## Filtering, Sorting & Pagination
```
GET /api/v1/users?status=active&role=admin     → filtering
GET /api/v1/users?sort=createdAt&order=desc    → sorting
GET /api/v1/users?cursor=xxx&limit=20          → cursor pagination
GET /api/v1/users?page=2&limit=20             → offset pagination (simple cases)
```

## Documentation
- Every endpoint must have OpenAPI (Swagger) or GraphQL schema documentation.
- Include: request params, request body, all possible responses (success + errors).
- Keep docs in sync with code — use code-first generation (tsoa, FastAPI, NestJS Swagger).
- Provide a Postman collection or HTTP file for quick testing.
