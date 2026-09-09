# Story E0-S3: Same-Origin Native Development Boundary
> Status: todo | Branch: feat/e0-s3-same-origin-dev

## WHAT — ต้องสร้างอะไร
ทำให้ browser-facing native development รักษา AlphaVoice same-origin contract: Next.js development origin รับ relative `/api/*` แล้ว proxy/rewrite ไปยัง native ASP.NET Core API โดย frontend application code ไม่ใช้ direct cross-origin backend URL.

### Acceptance Criteria
- [ ] AC-1: Next.js development server มี rewrite/proxy สำหรับ relative `/api/*` ไปยัง ASP.NET Core native process.
- [ ] AC-2: Minimal browser-facing API probe จาก frontend ใช้ relative `/api/...` เท่านั้น และสำเร็จผ่าน Next.js origin.
- [ ] AC-3: Normal frontend runtime configuration ไม่มี requirement ให้ browser เรียก direct ASP.NET port.
- [ ] AC-4: Direct ASP.NET port ยังคงใช้ได้สำหรับ tests/tooling ตาม Architecture โดยไม่กลายเป็น normal browser flow.
- [ ] AC-5: Story นี้ไม่เพิ่ม broad CORS policy หรือ development-only CSRF bypass เพื่อแก้ topology.
- [ ] AC-6: Behavior มี automated validation อย่างน้อยหนึ่งระดับที่พิสูจน์ browser-facing request path ผ่าน same origin.

## HOW — ทำอย่างไร
### Architecture Constraints
- Browser sees one origin: `/* → Next.js`, `/api/* → ASP.NET`.
- Development must preserve this via Next.js proxy/rewrite.
- No default Next.js BFF; proxy is transport/topology only, not duplicate business/auth logic.
- No broad CORS or dev-only CSRF exception as workaround.

### In Scope
- Next.js dev proxy/rewrite configuration.
- Minimal ASP.NET endpoint/probe only as needed to validate routing (no business endpoint).
- Frontend probe or automated test proving relative `/api/*` path.
- Development documentation of normal browser path vs direct API test/tooling path.

### Out of Scope
- Google authentication/session — E1.
- Full reverse proxy/containerized deployed topology — E12.
- CORS-based cross-origin frontend architecture.
- BFF business endpoints in Next.js.
- Product screens.

### Expected Change Surface
Prefer ≤4 logical areas and ≤250 implementation LOC.

### Test / Validation Expectations
- Run Web and API natively.
- Request `/api/...` against Next.js dev origin and assert ASP.NET response.
- Verify frontend config/source does not embed direct API origin for normal app requests.
- Verify no broad CORS/development auth bypass was added.

## WHY — ทำไมถึงเป็นแบบนี้
- **D6 — Same origin, no default BFF:** simplifies cookie/CORS/OAuth semantics and keeps ASP.NET as business API owner.
- **D26 — Native Web/API developer runtime:** preserves good hot reload/debugging while PostgreSQL stays containerized.
- **D28 — CSRF defense in depth:** development topology must not be “fixed” by weakening cookie-auth write protections.
- **AV-ARCH-06 remediation:** Phase 3 readiness explicitly required browser-facing native development to proxy `/api/*` through Next.js rather than switching to cross-origin behavior.

## User / System Value
Identity/session Stories can be implemented and tested in development using the same browser origin assumptions validated by Architecture instead of accumulating dev-only security exceptions.

## Requirements Covered
- Architecture/security prerequisite for FR-1–3 and all authenticated frontend flows.
- NFR-5 Authorization boundary foundation.

## Dependencies
- E0-S1 done/passed independent review.
- Does not require E0-S2 for the routing proof.

## Validation / Evidence
Required before `review`:
- automated same-origin routing test output;
- configuration/source evidence showing relative `/api/*` use;
- review confirmation: no broad CORS, no BFF business logic, no CSRF bypass.

## CONTEXT BUDGET — Dev โหลดแค่นี้
1. `docs/03-project-context.md`.
2. This Story file.
3. `docs/02-architecture.md`:
   - §2.2 Local runtime experience
   - §4.1 Rendering and data ownership
   - §6.3 Same-origin boundary
   - §6.4 CSRF (constraint awareness only)
   - §25 D6, D20, D26, D28
   - §26 AV-ARCH-06
   - §29 guardrails
4. E0-S1 completion evidence only for actual app paths/commands.

Do not load full PRD/UX.

## Authority / Escalation
If Next.js/.NET tooling makes the validated same-origin development contract infeasible without changing architecture, stop and record FINDING. Do not silently introduce cross-origin browser traffic, broad CORS, BFF business logic, or security exceptions.

## FINDINGS
_None at Story creation._
