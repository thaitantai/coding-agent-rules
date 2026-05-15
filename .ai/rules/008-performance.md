# Performance Standards

## Context
- Applies when building features that involve data fetching, rendering, or heavy computation.
- Measure before optimizing. Never optimize prematurely without profiling data.
- Performance budget: API responses < 200ms (p95), page LCP < 2.5s, INP < 200ms.

## Database & Queries
- Every query must use indexed columns in WHERE, JOIN, and ORDER BY clauses.
- Avoid N+1 queries — use eager loading / joins / DataLoader pattern.
- Paginate all list endpoints — never return unbounded lists.
- Use database-level aggregations (COUNT, SUM, AVG) instead of fetching and computing in code.
- Use connection pooling. Never open a new DB connection per request.
- Cache expensive, rarely-changing queries (user roles, config, lookup tables).

```ts
// ❌ N+1 — executes 1 + N queries
const orders = await Order.findAll();
for (const order of orders) {
  order.user = await User.findByPk(order.userId); // N extra queries!
}

// ✅ Eager loading — 1 query with JOIN
const orders = await Order.findAll({ include: [User] });
```

## Caching Strategy
```
L1: In-memory (process)    → use for: config, lookup tables, computed constants
L2: Redis / Memcached      → use for: session data, rate limits, hot API responses
L3: CDN                    → use for: static assets, public API responses, images
Database query cache        → use for: expensive aggregations, reports
```

- Cache keys must be specific and versioned: `user:${id}:profile:v2`.
- Set appropriate TTLs — never cache indefinitely without a clear invalidation strategy.
- Cache stampede protection: use probabilistic early expiry or lock-based refresh.

## API & Network
- Compress responses with gzip/brotli for all text responses.
- Use HTTP/2 when possible — multiplexing reduces connection overhead.
- Paginate with cursor-based pagination for large datasets (more efficient than offset).
- Batch multiple requests where possible (GraphQL batching, DataLoader, REST bulk endpoints).
- Set response timeouts — never let a request hang indefinitely.

```ts
// ✅ Cursor-based pagination
async function listUsers(cursor?: string, limit = 20): Promise<Page<User>> {
  const users = await db.users.findMany({
    take: limit + 1,
    cursor: cursor ? { id: cursor } : undefined,
    orderBy: { createdAt: 'desc' },
  });
  const hasMore = users.length > limit;
  return {
    data: users.slice(0, limit),
    nextCursor: hasMore ? users[limit - 1].id : null,
  };
}
```

## Frontend Performance
- Images: use modern formats (WebP/AVIF), lazy load below the fold, set explicit dimensions.
- Fonts: use `font-display: swap`, subset fonts, self-host if possible.
- Code splitting: lazy load routes and heavy components. Never bundle everything upfront.
- Memoize expensive computations: `useMemo`, `useCallback` — but only when profiling shows a need.
- Avoid layout thrash: batch DOM reads and writes separately.
- Virtualize long lists (> 100 items): `react-virtual`, `react-window`.

```tsx
// ✅ Code splitting a heavy component
const ChartComponent = lazy(() => import('./ChartComponent'));

function Dashboard() {
  return (
    <Suspense fallback={<Skeleton />}>
      <ChartComponent />
    </Suspense>
  );
}
```

## Background Jobs & Heavy Computation
- Move heavy computation off the request thread — use queues (BullMQ, Celery, SQS).
- CPU-bound work: offload to worker threads or a separate service.
- Implement idempotency on jobs — jobs must be safe to retry without side effects.
- Set job timeouts and dead-letter queues to handle stuck jobs.

## Measurement
- Profile before optimizing. Use: Chrome DevTools, Clinic.js (Node), py-spy (Python).
- Track Core Web Vitals in production: LCP, INP, CLS.
- Set up APM (Datadog, New Relic, or open-source Grafana stack) to monitor p50/p95/p99 latencies.
- Load test critical paths before launch: k6, Locust, or Artillery.
