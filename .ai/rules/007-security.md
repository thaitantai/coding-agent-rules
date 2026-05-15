# Security Standards

## Context
- Applies to all code touching auth, data handling, APIs, and user input.
- Security bugs are production incidents. Treat them with highest priority.
- When in doubt, choose the more secure option. Always.

## Secrets & Credentials
- Never hardcode secrets, API keys, tokens, or passwords in source code.
- All secrets via environment variables only. Parse and validate with a schema (e.g., Zod).
- Never log secrets — mask them in logs: `logger.info({ userId }, 'Login attempt')`.
- `.env` files are gitignored. Provide `.env.example` with placeholder values.
- Rotate any secret that has been accidentally committed immediately.

```ts
// ❌ Never do this
const client = new StripeClient('sk_live_abc123...');

// ✅ Always this
const STRIPE_SECRET = z.string().min(1).parse(process.env.STRIPE_SECRET_KEY);
const client = new StripeClient(STRIPE_SECRET);
```

## Input Validation & Sanitization
- Validate ALL external input at the boundary (API routes, CLI args, file uploads).
- Use an allowlist approach — define what is valid, reject everything else.
- Sanitize HTML input to prevent XSS. Use `DOMPurify` (client) or `sanitize-html` (server).
- Never use user input directly in SQL queries — always use parameterized queries / ORM.
- Validate file uploads: check MIME type, size limit, file extension, and scan for malware paths.

```ts
// ❌ SQL injection risk
const user = await db.query(`SELECT * FROM users WHERE email = '${email}'`);

// ✅ Parameterized query
const user = await db.query('SELECT * FROM users WHERE email = $1', [email]);
```

## Authentication & Authorization
- Passwords: hash with bcrypt (cost factor ≥ 12) or argon2id. Never MD5/SHA1 for passwords.
- Sessions: use secure, httpOnly, sameSite cookies. Never store tokens in localStorage.
- JWTs: short expiry (15min access, 7d refresh). Validate signature and expiry on every request.
- Always check authorization AFTER authentication — authenticate who, authorize what.
- Implement rate limiting on auth endpoints (login, password reset, OTP).
- Never expose internal user IDs in URLs if possible — use opaque tokens or UUIDs.

```ts
// ✅ Authorization check in service layer
async function deletePost(postId: string, requesterId: string): Promise<void> {
  const post = await postRepo.findById(postId);
  if (!post) throw new NotFoundError('Post not found');
  if (post.authorId !== requesterId) throw new ForbiddenError('Not your post');
  await postRepo.delete(postId);
}
```

## API Security
- Set security headers: `Content-Security-Policy`, `X-Content-Type-Options`, `Strict-Transport-Security`.
- Use `helmet` (Node.js) or equivalent for baseline security headers.
- CORS: allowlist specific origins — never `*` in production.
- Rate limit all public endpoints. Auth endpoints need stricter limits.
- Never expose stack traces or internal error details to API consumers.

```ts
// ✅ Safe error response
// What the client sees:
{ "error": "Internal server error", "requestId": "abc-123" }

// What the logs capture:
logger.error({ err, requestId }, 'Unhandled error in createUser');
```

## Dependency Security
- Run `npm audit` / `pip-audit` / `cargo audit` in CI. Fail on high/critical vulnerabilities.
- Pin major versions in `package.json`. Use lockfiles (`package-lock.json`, `poetry.lock`).
- Review new dependencies before adding: check download count, last publish date, maintainers.
- Prefer established libraries over unknown ones for security-critical functionality.

## Data Privacy
- Collect only what you need — data minimization principle.
- PII (names, emails, IPs) must be encrypted at rest and in transit (TLS).
- Never log PII. If needed for debugging, mask it: `user@e***.com`.
- Implement data retention policies — delete data that is no longer needed.
- Know your GDPR/CCPA obligations if handling EU/California user data.
