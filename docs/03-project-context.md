# Project Context — AlphaVoice
> Load every session. Keep ≤60 lines. Architecture status: VALIDATED — Phase 3 Architecture / Readiness Gate passed 2026-09-05.
## Product invariants
- Precision > Coverage > Speed; uncertain Candidates never appear to regular users.
- One Public Appearance = one Canonical Event; multiple Resources attach beneath it.
- Monitoring is Watchlist-driven; Global discovery/backfill state is shared across users.
- Historical outcome uses PRD `(S,F)` only: Y/N Complete, Y/Y Partial, N/Y Failed, N/N Unsupported.
- Email/push, default paid AI, default transcription, and unlimited backfill are out of MVP.
## Locked stack
- Frontend: React + Next.js + TypeScript; authenticated data comes from ASP.NET `/api/*` on the same origin.
- Backend: ASP.NET Core on latest stable supported .NET LTS; modular monolith, worker-separable later.
- Database: PostgreSQL; EF Core primary, explicit SQL/Dapper allowed when justified/tested.
- Sessions: PostgreSQL-backed authoritative server session + opaque Secure HttpOnly SameSite cookie; expiry/logout/revocation/cleanup are server-side; no JWT access/refresh MVP.
- Background: PostgreSQL durable jobs + scheduler + transactional outbox; no Redis/broker required.
- Contracts: ASP.NET OpenAPI → generated TypeScript client/types.
## Domain boundaries
- Business-first modules: Identity, StockUniverse, Watchlists, Executives, Events, Discovery, Backfill, AdminReview, Operations, Audit.
- PostgreSQL schema-per-domain; writes go through owning module; cross-module atomic use cases may share one PostgreSQL transaction coordinated by the application layer, never direct foreign-schema writes.
- Candidate and CanonicalEvent are separate; Source Adapters emit normalized items and never create Events directly.
- Event can have multiple EventParticipants (Executive + Company + role-at-event); mention-only is not participation.
- EventReadState is persistent User×Event history; Unread is derived from Watchlist + Published Event + ReadState.
## Data correctness
- Business dates use DATE; operations use UTC; FollowedAt→UTC FollowDate drives inclusive [D-90,D] coverage; PrimaryEventDate remains evidence-based.
- ExecutiveRole and CompanyListing are effective-dated histories; do not overwrite historical identity/state.
- Backfill Job ≠ Attempt ≠ Effective Coverage; retry only Failed; reuse Succeeded source/date ranges.
- Event correction keeps authoritative current state + material revision/audit; false positives become Suppressed, not deleted.
- Candidate/published merges reconcile validated EventParticipants + Resources; published duplicate Events use survivor aliases and transactionally reconcile ReadState/audit/outbox.
## Discovery / external sources
- Structured-first: official API → RSS/feed → official/public HTML → governed broader web/search.
- Discovery is deterministic/cheap-first; AI escalation is future/optional and requires evidence + owner cost approval.
- Source set, numeric confidence thresholds, and actual cadences remain provisional until the frozen Discovery Spike.
- HTTP first; outbound fetches use safe schemes + DNS/IP/redirect/size/timeout egress guards; BrowserFetch is optional, isolated, secret/filesystem-minimal, and Spike-gated.
- External content is untrusted: plain text default; only strictly sanitized limited rich content; never arbitrary source HTML.
## Security / operations
- Internal UserId + ExternalIdentity(Google sub); email is not an auth key; Admin role is persisted after bootstrap.
- User-specific requests derive UserId from session; never trust client-supplied ownership IDs; Admin does not bypass user isolation.
- Unsafe cookie-authenticated writes require CSRF protection + Origin/Referer + authorization + DB constraints.
- Typed domain/application errors map to stable HTTP error codes; Admin Candidate resolve is optimistic + DB resolve-once.
- Config is layered; secrets never committed; runtime source settings live in PostgreSQL where appropriate.
- Automated local PostgreSQL backup + repeatable restore test; migrations are controlled forward release steps.
## Repo / build / test
- Structured monorepo; Web/API/future Worker build/deploy independently despite one repository.
- Dev: Next.js + ASP.NET native, PostgreSQL container; browser still uses same-origin Next.js `/api/*` proxy/rewrite; deployed Local MVP uses one-command containerized stack.
- CI tiers: build/lint/type/unit/contract → PostgreSQL/security/container → selected E2E → controlled benchmark evidence.
- Core tests must cover PostgreSQL constraints/transactions, user isolation, `(S,F)`, role-at-date, idempotency, outbox, merge/concurrency.
## Do not violate
- Do not add paid recurring services, Redis, message broker, search SaaS, hosted observability, or paid AI without owner approval/evidence.
- Do not expose EF entities as API contracts or hand-edit generated TypeScript contract code.
- Do not derive backfill truth from job status; do not treat OpenCircuit as Unsupported.
- Do not let source adapters write Canonical Events directly or let modules write another module's owned tables directly.
- Do not begin implementation coding without a Phase 4 Story that has passed the required BMAD Context Budget / Review gates.
- If reality contradicts architecture, stop and use BMAD FINDINGS → Architect/ADR flow before changing code against the docs.
