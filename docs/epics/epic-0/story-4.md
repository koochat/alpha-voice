# Story E0-S4: OpenAPI Contract Generation & Baseline CI
> Status: todo | Branch: feat/e0-s4-contract-ci

## WHAT — ต้องสร้างอะไร
สร้าง ASP.NET OpenAPI → generated TypeScript client/types pipeline และ baseline deterministic CI Gate 1 ที่ตรวจ frontend lint/type/build, .NET build/tests ที่มี, และ generated-contract drift โดยยังไม่มี product API contracts.

### Acceptance Criteria
- [ ] AC-1: ASP.NET Core host สามารถ produce OpenAPI document จาก API contract source of truth ได้.
- [ ] AC-2: Repository มี repeatable generation command/process ที่สร้าง TypeScript client/types ลง generated contract area จาก OpenAPI.
- [ ] AC-3: Generated TypeScript artifacts ระบุ/จัดการเป็น generated code และไม่ต้อง hand-maintain.
- [ ] AC-4: CI มี deterministic Gate-1 steps อย่างน้อย frontend lint/type-check/build, .NET restore/build/test ที่มี, และ contract-generation drift check.
- [ ] AC-5: CI drift check fail เมื่อ OpenAPI-derived generated artifact ไม่ตรงกับ source contract และ pass หลัง regeneration.
- [ ] AC-6: Story นี้ไม่สร้าง business endpoints เพียงเพื่อเติม contract surface; minimal framework/sample contract ใช้ได้เฉพาะที่จำเป็นต่อการพิสูจน์ pipeline.
- [ ] AC-7: Live external-source tests, Discovery benchmarks, PostgreSQL security suite, selected E2E และ evidence Gate 4 ไม่ถูกยัดเข้า deterministic baseline CI Story นี้.

## HOW — ทำอย่างไร
### Architecture Constraints
- ASP.NET owns OpenAPI contract.
- TypeScript client/types are generated; do not expose EF entities directly.
- CI is tiered; Gate 1 is cheap/deterministic.
- External/live-source validation must remain controlled/on-demand.

### In Scope
- OpenAPI document generation/exposure for build tooling.
- One deterministic TypeScript client/type generation mechanism.
- Generated artifact location and developer command.
- CI Gate-1 workflow/script.
- Deliberate contract-drift validation.

### Out of Scope
- Product screen endpoints.
- PostgreSQL integration/security/container Gate 2 beyond what E0-S2 may already provide locally.
- Selected E2E Gate 3.
- Discovery/Backfill/Duplicate/Performance/Cost Gate 4.
- Hand-written duplicate TS DTO layer.

### Expected Change Surface
Prefer ≤5 logical areas and ≤400 net implementation LOC excluding generated client output and CI boilerplate.

### Test / Validation Expectations
- Generate OpenAPI.
- Generate TypeScript contract artifacts.
- Demonstrate clean drift check.
- Make a controlled temporary contract change in test/validation process and prove drift check detects it, then restore.
- Run Gate-1 CI locally or in configured CI environment.

## WHY — ทำไมถึงเป็นแบบนี้
- **D25 — OpenAPI → generated TypeScript:** prevents backend/frontend DTO drift and keeps ASP.NET as contract owner.
- **D58 — Tiered CI:** cheap deterministic failures should block early; unstable external/live evidence must not break unrelated PRs.
- Explicit DTO contracts keep EF persistence entities from becoming public API shape by accident.

## User / System Value
ทุก vertical Story หลังจากนี้สามารถเพิ่ม API contract แล้วได้ frontend types/client ที่ sync โดยอัตโนมัติ พร้อม cheap CI feedback ก่อนเข้าสู่ PostgreSQL/security/E2E evidence gates ที่แพงกว่า.

## Requirements Covered
- NFR-13 Evidence foundation.
- Contract/testing foundation for all API-facing FRs.

## Dependencies
- E0-S1 done/passed independent review.
- May integrate with E0-S2 if database smoke test already exists, but E0-S2 is not required to define contract generation itself.

## Validation / Evidence
Required before `review`:
- successful OpenAPI generation output;
- generated TypeScript artifact sample;
- Gate-1 CI pass;
- recorded demonstration that intentional contract drift is detected;
- review that no EF entity exposure/business endpoints were introduced as shortcuts.

## CONTEXT BUDGET — Dev โหลดแค่นี้
1. `docs/03-project-context.md`.
2. This Story file.
3. `docs/02-architecture.md`:
   - §3 Contract sync
   - §14.1 API shape (DTO ownership constraint only)
   - §14.4 Contract generation
   - §20.2 Tiered CI — Gate 1 and live-source note
   - §21 Testing Strategy — contract checks
   - §25 D25, D31, D58
   - §29 guardrails
4. E0-S1 completion evidence only for actual build commands/repository paths.

Do not load PRD/UX.

## Authority / Escalation
If the chosen generation tool materially changes API ownership, requires a recurring paid service, or forces hand-maintained duplicate TypeScript contracts, stop and record FINDING before proceeding.

## FINDINGS
_None at Story creation._
