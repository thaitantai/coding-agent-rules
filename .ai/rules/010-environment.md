# Environment & Deployment Standards

## Context
- Applies to environment configuration, CI/CD pipelines, and deployment processes.
- Goal: reproducible builds, zero-downtime deploys, and clear environment separation.

## Environment Separation
- Always maintain at least 3 environments: `development`, `staging`, `production`.
- Config differs between environments — code does not. Never use `if (env === 'production')` in business logic.
- Each environment has its own: database, secrets, external service credentials.
- Staging must mirror production architecture — it is where you validate before release.

## Environment Variables
- All configuration via env vars — no hardcoded values for anything that changes per environment.
- Parse and validate all env vars at startup using a schema. Fail fast if required vars are missing.
- Group and document vars in `.env.example`:

```bash
# App
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/myapp

# Auth
JWT_SECRET=             # min 32 chars random string
JWT_EXPIRES_IN=15m

# External Services
STRIPE_SECRET_KEY=      # sk_test_... for dev, sk_live_... for prod
SENDGRID_API_KEY=
```

## Docker & Containerization
- Use multi-stage Dockerfile: `builder` stage → `runner` stage (minimal final image).
- Run as non-root user inside containers.
- Use `.dockerignore` to exclude `node_modules`, `.git`, test files, local configs.
- Pin base image versions: `node:20.11-alpine` not `node:latest`.
- Health check endpoint: `GET /health` returns `200` with service status.

```dockerfile
# ✅ Multi-stage example
FROM node:20.11-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20.11-alpine AS runner
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER appuser
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

## CI/CD Pipeline
Every PR must pass this pipeline before merge:
```
1. Install dependencies (cached)
2. Type check (tsc --noEmit)
3. Lint (ESLint / Ruff)
4. Unit tests (with coverage threshold)
5. Integration tests
6. Build (must succeed)
7. Security audit (npm audit / pip-audit)
```

On merge to main:
```
8.  Build Docker image
9.  Push to registry (tagged with git SHA)
10. Deploy to staging (auto)
11. Run smoke tests against staging
12. Deploy to production (manual approval or auto with monitoring)
```

## Health & Observability
Every service must expose:
```
GET /health        → liveness check (is the process alive?)
GET /health/ready  → readiness check (is the service ready to serve traffic?)
```

Readiness check validates: DB connection, Redis connection, required external services.

Structured logging (JSON format):
```json
{
  "level": "info",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "abc-123",
  "userId": "user-456",
  "message": "User login successful",
  "duration": 45
}
```

Log levels: `error` (needs immediate action), `warn` (needs attention), `info` (normal events), `debug` (dev only).

## Database Migrations
- All schema changes via migration files — never edit production schema manually.
- Migrations are forward-only in production. Rollback = new migration.
- Test migrations on a copy of production data before deploying.
- Migration naming: `YYYYMMDDHHMMSS_description.sql` or framework convention.
- Migrations must be idempotent where possible.

## Zero-Downtime Deployment Checklist
- [ ] New code is backward-compatible with old DB schema (expand-contract pattern).
- [ ] Feature flags enabled for large changes.
- [ ] Graceful shutdown implemented (drain requests before stopping).
- [ ] DB migrations run before code deployment, not simultaneously.
- [ ] Rollback plan documented and tested.
- [ ] Alerts and dashboards updated for new metrics.
