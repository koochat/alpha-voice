# Story E0-S2: PostgreSQL Development Baseline
> Status: todo | Branch: feat/e0-s2-postgres-baseline

## WHAT — ต้องสร้างอะไร
สร้าง PostgreSQL development baseline สำหรับ AlphaVoice: local PostgreSQL container, API database configuration, EF Core migration infrastructure และ fresh-database smoke validation โดยยังไม่สร้าง business/domain schema.

### Acceptance Criteria
- [ ] AC-1: Development environment สามารถ start PostgreSQL แบบ containerized ได้ด้วย configuration ที่อยู่ใน repo โดยไม่มี secret จริงถูก commit.
- [ ] AC-2: ASP.NET Core API สามารถเชื่อม PostgreSQL ผ่าน layered configuration และ secret mechanism ที่เหมาะกับ local development.
- [ ] AC-3: EF Core เป็น primary data-access/migration baseline; migration tooling สามารถสร้าง/apply controlled baseline migration ได้.
- [ ] AC-4: Disposable/fresh PostgreSQL database สามารถ apply migration chain จากศูนย์และผ่าน API/database smoke check ได้.
- [ ] AC-5: ไม่มี application startup behavior ที่ให้ทุก API instance auto-run uncontrolled migrations เป็น production assumption.
- [ ] AC-6: ไม่มี business-domain tables/entities ถูกเพิ่มใน Story นี้ นอกจาก technical migration marker/schema ที่จำเป็นจริง ๆ สำหรับ tooling.
- [ ] AC-7: In-memory database substitute ไม่ถูกใช้เป็นหลักฐานสำหรับ PostgreSQL migration/connection behavior.

## HOW — ทำอย่างไร
### Architecture Constraints
- PostgreSQL from day one.
- EF Core primary; explicit SQL/Dapper only when justified/tested — not needed by default here.
- Versioned forward migrations; migrations are controlled release steps.
- Development: PostgreSQL containerized while Web/API remain native.
- Secrets never committed.

### In Scope
- PostgreSQL local container definition/configuration.
- API PostgreSQL provider/configuration wiring.
- EF Core migration project/tooling choice consistent with current repo structure.
- Baseline migration path and disposable fresh-DB smoke test.
- Local non-secret configuration example/documentation.

### Out of Scope
- Domain schemas for Identity, Watchlists, Events, etc.
- Backup/restore automation — E12.
- One-command deployed local stack — E12.
- Dapper/hand-tuned SQL.
- Managed/paid PostgreSQL service.

### Expected Change Surface
Prefer ≤5 logical areas and ≤400 net implementation LOC excluding generated migration metadata/tool lockfiles.

Likely areas:
1. PostgreSQL container/local infra file;
2. API package/config wiring;
3. persistence/migration bootstrap area;
4. baseline migration artifact;
5. integration/smoke test or local documentation.

### Test / Validation Expectations
- Start disposable PostgreSQL.
- Apply migrations from empty state.
- API or dedicated smoke test opens connection successfully.
- Failure case for absent/invalid configuration is bounded and does not expose secrets.

## WHY — ทำไมถึงเป็นแบบนี้
- **D3 — PostgreSQL from day one:** AlphaVoice relies on relational constraints, transactions and query semantics central to later correctness stories.
- **D8 — EF Core primary:** maximize productivity while retaining explicit SQL/Dapper escape hatch only when evidence requires it.
- **D49 — Controlled versioned migrations:** schema changes must be release-controlled, not silently applied by every runtime instance.
- Using the real PostgreSQL engine now prevents later tests from proving behavior against an incompatible in-memory substitute.

## User / System Value
ทุก domain Story หลังจากนี้สามารถใช้ database semantics เดียวกับ production/local MVP และสร้าง integration evidence ที่เชื่อถือได้.

## Requirements Covered
- Foundation for NFR-12 Data Integrity.
- Foundation for NFR-13 Evidence.
- Architecture prerequisite for later FR implementation.

## Dependencies
- E0-S1 done/passed independent review.

## Validation / Evidence
Required before `review`:
- fresh PostgreSQL startup evidence;
- migration apply-from-zero result;
- API/database connectivity smoke result;
- secret/config review;
- confirmation that no business schema slipped into Story scope.

## CONTEXT BUDGET — Dev โหลดแค่นี้
1. `docs/03-project-context.md`.
2. This Story file.
3. `docs/02-architecture.md`:
   - §2.2 Local runtime experience
   - §3 Technology Stack (Database/Data access)
   - §17.3 Schema migration
   - §18 Configuration and Secrets
   - §21 Testing Strategy (PostgreSQL note)
   - §25 D3, D8, D26, D37, D49
   - §29 guardrails
4. E0-S1 completion evidence/contracts only if needed to resolve actual repository paths.

Do not load PRD/UX.

## Authority / Escalation
If EF Core/PostgreSQL integration requires a material architecture change, paid database, alternate primary DB, or uncontrolled migration model, stop and record FINDING. Do not substitute SQLite/in-memory as the implementation truth.

## FINDINGS
_None at Story creation._
