# Epic E0 — Engineering Foundation & Local Runtime
> Planning status: sharded | Coding authorization: NONE until individual Story gate passes

## Objective
Establish the smallest validated engineering substrate required by later AlphaVoice implementation without implementing product/domain behavior.

## Story Order
1. **E0-S1 — Structured Monorepo Bootstrap** — prerequisite for all E0 work.
2. **E0-S2 — PostgreSQL Development Baseline** — after E0-S1.
3. **E0-S3 — Same-Origin Native Development Boundary** — after E0-S1; can run independently/in parallel with E0-S2 after separate Story review.
4. **E0-S4 — OpenAPI Contract Generation & Baseline CI** — after E0-S1; can run independently/in parallel after separate Story review.

## Dependency Graph
```text
E0-S1
├── E0-S2
├── E0-S3
└── E0-S4
```

## Epic Exit Criteria
- Web/API structured monorepo boundaries exist and build independently.
- Local PostgreSQL development baseline and controlled migration path exist.
- Browser-facing native development uses same-origin Next.js `/api/*` proxy/rewrite.
- ASP.NET OpenAPI generates TypeScript contracts and cheap deterministic CI detects drift.
- No business feature, paid recurring service, Redis/broker/search SaaS/paid AI or BrowserFetch is introduced by foundation work.

## Review Rule
Each Story is implemented and independently reviewed separately. Completing E0-S1 does not authorize a developer to continue directly into E0-S2/S3/S4 in the same Dev context.
