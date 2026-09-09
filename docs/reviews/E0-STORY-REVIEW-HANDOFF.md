# AlphaVoice — E0 Story Review Handoff
> Role requested: Independent Story / Context-Budget Reviewer
> Scope: Phase 4 Epic E0 only
> Coding authorization: NONE

## Review Inputs
Use only:
1. `docs/03-project-context.md` — final VALIDATED v0.2 Project Context.
2. `docs/02-architecture.md` — final VALIDATED Architecture v0.2, only the sections referenced by each Story plus §29 guardrails.
3. `docs/epics/epic-0/story-1.md`
4. `docs/epics/epic-0/story-2.md`
5. `docs/epics/epic-0/story-3.md`
6. `docs/epics/epic-0/story-4.md`
7. `docs/epics/epic-0/EPIC-0-INDEX.md`

Do not use the stale Architecture v0.1 or pre-housekeeping Project Context.

## Reviewer Task
Review E0-S1 through E0-S4 independently. Do not implement code and do not silently change validated Architecture.

For each Story verify:
- WHAT is one coherent implementation objective.
- Scope is suitable for one focused Dev session; if likely too large, require sharding before Dev.
- Acceptance Criteria are objective/testable and collectively prove the Story goal.
- In Scope / Out of Scope prevent premature domain/product implementation.
- Dependencies are sufficient and non-circular.
- WHY correctly preserves the relevant validated decisions.
- Context Budget is minimal but sufficient; Dev should not need the full PRD/UX/Architecture.
- No Story adds a recurring paid dependency, Redis, broker, search SaaS, hosted observability, paid AI, or BrowserFetch.
- E0-S3 preserves AV-ARCH-06: browser-facing development uses Next.js same-origin `/api/*` proxy/rewrite and does not solve dev routing with broad CORS or CSRF exceptions.
- E0-S2 preserves PostgreSQL from day one, EF Core primary, controlled forward migrations and real PostgreSQL validation.
- E0-S4 preserves ASP.NET OpenAPI as contract source of truth and generated TypeScript code as non-hand-maintained output.
- No Story accidentally authorizes implementation of another Story.

## Required Verdict Format
For each Story return one of:
- `PASS — implementation-ready after owner authorizes Dev`
- `PASS WITH CHANGES — list exact Story-document edits required before Dev`
- `FAIL — story must be reshaped before Dev`

Then give an Epic-level verdict:
- `E0 STORY GATE: PASS`
- or `E0 STORY GATE: NOT READY`

Report findings by severity: BLOCKER / MAJOR / MINOR / NOTE.
Do not invent issues for review theater; if a Story is already good, say PASS.

## Important Gate Rule
A PASS authorizes only the owner to choose the next Dev Story. It does not authorize the reviewer or Scrum Master to start coding automatically.
