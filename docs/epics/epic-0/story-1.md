# Story E0-S1: Structured Monorepo Bootstrap
> Status: done | Branch: feat/e0-s1-monorepo-bootstrap

## WHAT — ต้องสร้างอะไร
สร้าง structured monorepo skeleton สำหรับ AlphaVoice ที่มี Next.js Web, ASP.NET Core API, backend module root, test roots และคำสั่ง build/lint/type-check ขั้นพื้นฐาน โดยยังไม่มี business feature implementation.

### Acceptance Criteria
- [ ] AC-1: Repository มี application boundaries อย่างน้อย `apps/web`, `apps/api`, `backend/modules`, `tests`, `contracts/generated`, `infra`, และ `docs` ตาม architecture intent หรือชื่อที่เทียบเท่าโดยไม่เปลี่ยน ownership model.
- [ ] AC-2: Next.js + TypeScript application สามารถติดตั้ง dependency และผ่าน type-check/build ขั้นพื้นฐานได้.
- [ ] AC-3: ASP.NET Core application บน latest stable supported .NET LTS ณ implementation kickoff สามารถ restore/build ได้โดยไม่ใช้ preview runtime.
- [ ] AC-4: Web และ API build ได้แยกจากกัน แม้อยู่ repository เดียวกัน.
- [ ] AC-5: Backend structure เป็น business/feature-first foundation และไม่สร้าง global `Controllers/Services/Repositories` architecture เป็น default organization.
- [ ] AC-6: ไม่มี business/domain behavior, database schema, authentication, Discovery source, Redis, broker, paid service หรือ BrowserFetch ถูกเพิ่มใน Story นี้.
- [ ] AC-7: Developer-facing commands สำหรับ frontend install/type-check/build และ backend restore/build ถูกบันทึกใน repository-level developer documentation ที่ Story นี้สร้าง/แก้.

## HOW — ทำอย่างไร
### Architecture Constraints
- Structured monorepo; Web/API/future Worker ต้องสามารถ build/deploy independently.
- Frontend = React + Next.js + TypeScript.
- Backend = ASP.NET Core on latest stable supported .NET LTS; no preview runtime.
- Backend organization = business/feature-first modular-monolith foundation.
- ห้ามเพิ่ม recurring-cost infrastructure dependency.

### In Scope
- Bootstrap Next.js + TypeScript application shell.
- Bootstrap ASP.NET Core API host shell.
- Establish repository directories/boundaries needed by validated architecture.
- Establish minimum root-level developer commands/docs for independent Web/API build.
- Add only minimal tool/config files required for those shells.

### Out of Scope
- PostgreSQL container or EF migrations — E0-S2.
- `/api/*` development proxy — E0-S3.
- OpenAPI generated TypeScript pipeline / CI — E0-S4.
- Identity/auth/session/domain modules.
- Product screens beyond framework-generated/minimal shell.
- Domain tables/entities.
- Redis, message broker, search SaaS, hosted observability, AI, BrowserFetch.

### Expected Change Surface
Target ≤5 logical implementation areas and ≤400 net implementation LOC excluding package-manager generated lockfiles/tool scaffolding. If framework bootstrap generates substantial boilerplate, treat generated files as scaffolding rather than expanding product scope.

Likely areas:
1. repository/root configuration or developer README;
2. `apps/web` shell;
3. `apps/api` shell;
4. `backend/modules` placeholder/boundary marker;
5. `tests`/supporting root structure.

### Test / Validation Expectations
- Frontend type-check and production build.
- Backend restore/build.
- Verify both can execute independently.
- Verify no preview .NET runtime and no prohibited infrastructure dependency entered manifests.

## WHY — ทำไมถึงเป็นแบบนี้
- **D2 — Modular monolith, worker-separable:** เริ่มง่ายใน process เดียวแต่ repository/runtime boundaries ต้องไม่ขวาง future API/Worker split.
- **D5 — Selected stack:** owner ล็อก React/Next.js/TypeScript + ASP.NET Core/.NET LTS.
- **D43 — Business/feature backend organization:** ป้องกัน horizontal global-layer structure ที่ทำให้ module ownership เบลอ.
- **D57 — Structured monorepo:** ทำให้ frontend/backend/contracts/tests เคลื่อนร่วมกันได้ แต่ deployment boundaries ยังแยกได้.
- Story นี้มีไว้สร้างฐานที่ Story อื่นอ้างอิงได้ โดยไม่แอบตัดสิน domain/API/database ก่อนเวลา.

## User / System Value
ทีมสามารถเริ่ม Story ต่อ ๆ ไปบน repository structure ที่สอดคล้องกับ Architecture และสามารถ validate Web/API แยกกันได้ตั้งแต่ commit แรก.

## Requirements Covered
- Architecture readiness foundation for all FRs.
- NFR-13 Evidence / repeatable validation foundation.
- Does not independently complete a product FR.

## Dependencies
- Phase 3 Architecture v0.2 VALIDATED.
- Phase 4 Epic structure Option A approved by owner.
- No implementation Story dependency.

## Validation / Evidence
Required before Story may move to `review`:
- command output showing frontend type-check/build pass;
- command output showing .NET restore/build pass;
- repository tree snapshot sufficient to inspect boundaries;
- dependency/manifests review showing no prohibited recurring infrastructure or preview runtime.

Independent Review must check:
1. AC coverage;
2. architecture boundaries;
3. no premature business/domain implementation;
4. no hidden recurring-cost service.

Independent implementation review: PASS
Review: docs/reviews/e0-s1-independent-implementation-review-result-v0.1.md
Findings: 0 BLOCKER / 0 MAJOR / 0 MINOR / 0 NOTE

## CONTEXT BUDGET — Dev โหลดแค่นี้
1. `docs/03-project-context.md` — entire file, always authoritative implementation constitution.
2. This Story file.
3. `docs/02-architecture.md`:
   - §3 Technology Stack
   - §5 Backend Modular Monolith (intro only)
   - §20.1 Structured Monorepo
   - §25 decisions D2, D5, D43, D57
   - §29 Readiness / Implementation Guardrails

Do **not** load the full PRD or UX Spec for this Story; no product behavior is implemented.

## Authority / Escalation
If tool/framework bootstrap reality requires changing the validated stack, module ownership model, deployment boundary, or adding a new recurring-cost dependency, **STOP**. Record a FINDING and use the BMAD Architect/ADR flow before implementation continues. Do not silently choose another architecture.

## FINDINGS
_None at Story creation._
