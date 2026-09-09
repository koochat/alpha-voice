# PROJECT KICKOFF — BMAD Playbook · v1.3 (Guided / Pair Mode)

> **วิธีใช้:** copy ไปวางที่ root ของโปรเจกต์ใหม่ ทำตามจากบนลงล่าง ทุก section มี template + prompt ในตัว
> คนใหม่เริ่มจาก §6.2 (จับมือทำทีละ story) ก่อน กรอบชัดสุด แล้วค่อยขยับไป SM → Architect
>
> 🔧 **โหมดของเวอร์ชันนี้:** ในเฟส dev (Phase 4) AI **ไม่ลงมือเขียนโค้ดเอง** — AI เป็น **navigator** บอกทุกขั้นตอนพร้อมโค้ดเต็ม ให้ **คุณเป็น driver ลงมือพิมพ์/รันเอง** แล้วพอจบแต่ละหัวข้อค่อยส่งให้ AI (คนละ context) รีวิว · (เวอร์ชัน auto = AI implement ให้เลย ใช้ไฟล์ v1.2)
>
> ⚠️ **ไฟล์นี้ให้ "มนุษย์" อ่าน — ห้าม AI โหลดทั้งไฟล์** (ราว 6-8k token/turn) AI โหลดแค่ `.bmad-state.md` + `docs/03-project-context.md` (ตั้งค่าตาม §8) เปิด KICKOFF เฉพาะ section ที่สั่ง

**หลักการเหนือทุกอย่างในไฟล์นี้ — 4 ข้อ (ที่อื่นอ้างสั้น ๆ ไม่อธิบายซ้ำ):**
1. **State อยู่ในไฟล์ ไม่ใช่ในบทสนทนา** — ทุก decision จบที่ artifact
2. **ผู้สร้าง ≠ ผู้ตรวจ** — validate ด้วยโมเดลคนละตัว/context ใหม่เสมอ
3. **แก้เอกสารก่อนแก้โค้ด** — การเปลี่ยนทุกครั้งจบที่ artifact ก่อนแตะ implementation
4. **1 workflow = 1 context** — อย่าลากหลาย workflow ต่อกันใน context เดียว

---

## 0) TRIAGE — ประเมินขนาดก่อนเสมอ

BMAD เต็มรูปแบบแพง/ช้ากับงานเล็ก → route ตามขนาดก่อนเริ่มทุกครั้ง ตอบ 4 ข้อ (2 นาที ห้ามข้าม):

| คำถาม | ใช่ = +1 |
|---|---|
| แตะมากกว่า 3 module/service? | |
| มีคนทำต่อ / ต้อง onboard คนใหม่? | |
| ต้องการ audit trail / compliance / อธิบาย decision ย้อนหลัง? | |
| โปรเจกต์อยู่เกิน 1 เดือน? | |

- **0–1 → QUICK** — ข้าม Phase 1–3 เขียนแค่ `docs/mini-spec.md` (§Q) แล้วลุยโค้ด
- **2 → LEAN** — เขียน `docs/lean-spec.md` (§L) + constitution ย่อ แล้วเข้า Phase 4
- **3–4 → FULL** — เดินครบทุกเฟส

```
□ triage แล้ว ผลคือ: [ QUICK / LEAN / FULL ]
□ เหตุผล 1 บรรทัด: ______________________
```

---

## 1) โครงสร้างไฟล์มาตรฐาน (สร้างก่อนเริ่ม Phase 1)

```
project-root/
├── PROJECT_KICKOFF.md          ← ไฟล์นี้ (คู่มือมนุษย์)
├── CLAUDE.md                   ← มี pointer block จาก §8
├── docs/
│   ├── 00-brief.md             ← Phase 1
│   ├── 01-prd.md               ← Phase 2
│   ├── 01a-ux-spec.md          ← Phase 2.5 (เฉพาะมี UI)
│   ├── 02-architecture.md      ← Phase 3
│   ├── 03-project-context.md   ← "รัฐธรรมนูญ" — ไฟล์เดียวที่ AI โหลดทุก session
│   ├── epics/epic-N/story-N.md ← Phase 4 sharded stories
│   ├── decisions/ADR-NNN.md    ← decision หลัง architecture validate (§7.3)
│   ├── lean-spec.md            ← เฉพาะ LEAN
│   └── mini-spec.md            ← เฉพาะ QUICK
└── .bmad-state.md              ← state tracker (§2)
```

**เลขนำหน้า = ลำดับ pipeline:** ไฟล์ N คือ input ของไฟล์ N+1

---

## 2) STATE TRACKER — `.bmad-state.md`

ไฟล์เดียวที่ตอบ "อยู่ไหน ทำอะไรต่อ" — เปิด session ใหม่ AI อ่านไฟล์นี้ก่อนเสมอ (หลักการ #1)

```markdown
# BMAD State
- Flow type: [QUICK/LEAN/FULL]
- Current phase: [1-Analysis / 2-Planning / 2.5-UX / 3-Architecture / 4-Development]
- Artifacts done: [brief ✓ / prd ✓ / ux ✗ / arch ✗ / ...]
- Current epic/story: epic-2/story-3
- Current checkpoint: [checkpoint 2/4 ของ story นี้ — ทำถึงไหน]
- Blocked stories: [E1-S4: รอแก้ architecture — ดู findings ใน story file]
- Last session summary: (2-3 บรรทัด ทำล่าสุด + ค้างอะไร)
- Pending decisions: ...
```

**กติกา:** จบทุก session อัปเดตไฟล์นี้ก่อนปิด (30 วิ แลกกับไม่ต้อง reconstruct context ใน session ถัดไป)

---

## 3) PHASE 1 — ANALYSIS (optional ใน LEAN, required ใน FULL)

**Hat: Analyst** · **ทำที่: web UI / chat ปกติ (ไม่เปลือง context ใน IDE)**

```
สวมบทบาท Business Analyst ห้ามเขียนโค้ดหรือเสนอ solution ทางเทคนิคเด็ดขาด
หน้าที่เดียว: ขุดความต้องการจากผมให้ครบผ่านการถามทีละประเด็น

ไอเดียของผม: [เล่าไอเดียดิบ ๆ]

ถามทีละคำถาม (อย่าถามรวด 10 ข้อ) ครอบคลุม:
ปัญหาที่แก้ / ใครใช้ / ทำไมของที่มีอยู่ไม่พอ / นิยามความสำเร็จ /
constraint (เวลา งบ ทีม เทคโนโลยีที่ล็อก) / สิ่งที่ *ไม่* ทำ (non-goals)
เมื่อข้อมูลครบ สรุปเป็น Project Brief ตาม template ที่ผมให้
```

**Template `docs/00-brief.md`:**

```markdown
# Project Brief: [ชื่อ]
## ปัญหา (Problem)          ← 2-3 ประโยค ห้ามเกิน
## ผู้ใช้ (Users)            ← ใคร + สถานการณ์การใช้
## ความสำเร็จวัดจาก (Success Metrics)  ← ตัวเลขที่วัดได้จริง
## ขอบเขต (In Scope)
## นอกขอบเขต (Non-Goals)    ← สำคัญเท่า in-scope — กัน scope creep
## Constraints              ← เทคโนโลยี/เวลา/ทีม/งบ
## ความเสี่ยงหลัก (Top Risks)
```

**Gate:** อ่าน Brief แล้วตอบได้ไหมว่า "ถ้าสร้างตามนี้เสร็จ ถือว่าสำเร็จไหม" — ลังเล = กลับไปคุยกับ Analyst ต่อ

---

## 4) PHASE 2 — PLANNING → PRD

**Hat: PM** · **Input: `00-brief.md`** · **context ใหม่ (อย่าต่อจาก Analyst)**

```
สวมบทบาท Product Manager อ่าน Project Brief ที่แนบ แล้วสร้าง PRD
ก่อนเขียน: ถามเฉพาะจุดที่ Brief คลุมเครือหรือขัดกันเอง (ถ้ามี)
PRD ต้องมี: Functional Requirements (รหัส FR-1, FR-2...),
Non-Functional Requirements (รหัส NFR-1... ระบุตัวเลขวัดได้ เช่น p95 < 300ms),
Epic breakdown พร้อม story หยาบ ๆ ต่อ epic, ลำดับความสำคัญ (MoSCoW)
```

**Template `docs/01-prd.md`:**

```markdown
# PRD: [ชื่อ]
> Source: 00-brief.md | Version: 1.0 | Status: [draft/validated]

## Functional Requirements
| ID | Requirement | Priority | Epic |
|----|-------------|----------|------|
| FR-1 | ... | Must | E1 |

## Non-Functional Requirements
| ID | Category | Target (วัดได้) |
|----|----------|-----------------|
| NFR-1 | Performance | p95 latency < 300ms ที่ 100 RPS |

## Epics
### E1: [ชื่อ] — [1 บรรทัดว่าทำไม epic นี้ต้องมี]
- S1.1: [story หยาบ]

## Out of Scope (ยกจาก Brief + เพิ่มที่เจอระหว่างทำ PRD)
## Open Questions  ← คำถามที่ยังไม่มีคำตอบ ห้ามแกล้งลืม

## Changelog
- 1.0 (วันที่): initial validated version
```

### ✅ VALIDATION GATE (หลักการ #2 — โมเดลคนละตัว/แรงกว่า, context ใหม่)

```
คุณคือ reviewer อิสระที่ไม่มีส่วนได้เสีย จงหาจุดอ่อนใน PRD นี้:
1. FR ข้อไหนคลุมเครือจนตีความได้ 2 แบบ
2. NFR ข้อไหนวัดไม่ได้จริง
3. มี requirement ที่ขัดกันเองไหม
4. epic ไหนใหญ่เกินจะเสร็จใน scope เดียว
5. อะไรที่ *หายไป* จาก PRD ที่โปรเจกต์แบบนี้ควรมี
ตอบตรงไปตรงมา ถ้า PRD ดีอยู่แล้วให้บอกว่าผ่าน อย่าหาเรื่องติเพื่อให้ดูมีผลงาน
```

แก้ตามผล → Status = `validated` → ไปต่อ

---

## 4.5) PHASE 2.5 — UX SPEC (เฉพาะมี UI · ข้ามได้ถ้า API/service ล้วน)

**Hat: UX Expert** · **Input: `01-prd.md`** · **context ใหม่** · **ทำก่อน Architecture** (UX บอก Architect ว่าต้องมี endpoint/data อะไร)

```
สวมบทบาท UX Designer อ่าน PRD ที่แนบ ห้ามพูดเรื่อง implementation ทางเทคนิค
สร้าง UX Spec โดย: 1) ไล่ user flow หลักจาก FR ทีละตัว ถามผมเมื่อ flow มีทางแยกที่ PRD ไม่ระบุ
2) ทุกหน้าจอต้องระบุ 4 state: ปกติ / loading / empty / error — ห้ามข้าม
3) เสนอเป็นข้อความ/ASCII wireframe พอ เอาให้ Architect กับ Dev อ่านรู้เรื่อง
```

**Template `docs/01a-ux-spec.md`:**

```markdown
# UX Spec: [ชื่อ]
> Source: 01-prd.md | Status: [draft/validated]

## User Flows (flow หลักต่อ FR)
### Flow 1: [ชื่อ เช่น สมัครสมาชิก] — ตอบ FR-1, FR-2
[ขั้นตอน 1 → 2 → 3 พร้อมทางแยก ถ้า X ให้ไป Y]

## Screen Inventory
| Screen | หน้าที่ | ข้อมูลที่แสดง | Actions | FR ที่เกี่ยว |
|--------|---------|----------------|---------|--------------|
| S1: Login | ... | ... | ... | FR-1 |

## States ต่อหน้าจอ (บังคับครบ 4)
| Screen | Loading | Empty | Error | หมายเหตุ |
|--------|---------|-------|-------|----------|

## Component Patterns   ← ของที่ใช้ซ้ำ (ปุ่ม/ฟอร์ม/ตาราง/toast) — ตัดสินใจครั้งเดียวใช้ทุกจอ
## Platform Targets     ← desktop/mobile/responsive breakpoint ไหนบ้าง
## UX Non-Goals         ← เช่น "ยังไม่ทำ dark mode ใน v1"
```

**Gate:** ไล่ user flow เองหนึ่งรอบเหมือนผู้ใช้จริง — จุดที่คุณสะดุด คือจุดที่ Dev จะสะดุดคูณสอง
**ผลพลอยได้:** ตาราง Screen Inventory = input ตรงให้ Architect ออกแบบ API (จอไหนต้องการข้อมูลอะไร = endpoint อะไรต้องมี)

---

## 5) PHASE 3 — ARCHITECTURE + PROJECT CONSTITUTION

**Hat: Architect** · **Input: `01-prd.md` (+ `01a-ux-spec.md` ถ้ามี)** · **context ใหม่**

```
สวมบทบาท Software Architect อ่าน PRD (และ UX Spec ถ้าแนบ)
เสนอ architecture โดย: 1) เสนอทางเลือก 2-3 ทางพร้อม trade-off ก่อน อย่าเลือกให้ผมทันที
2) หลังผมเลือก จึงเขียน architecture doc เต็ม
3) ทุก decision สำคัญให้บันทึกเหตุผล "ทำไมเลือก X ไม่เลือก Y" — เหตุผลนี้จะถูกฝังใน story ภายหลัง
4) ถ้ามี UX Spec: ตรวจว่าทุก screen ใน Screen Inventory มี endpoint/data source รองรับครบ
```

**Template `docs/02-architecture.md`:**

```markdown
# Architecture: [ชื่อ]
> Source: 01-prd.md, 01a-ux-spec.md | Version: 1.0 | Status: [draft/validated]

## System Overview        ← diagram (mermaid ได้) + คำอธิบาย 1 ย่อหน้า
## Components & Contracts ← แต่ละ component: หน้าที่ / API contract / owner
## Data Model             ← ตารางหลัก + ความสัมพันธ์
## Key Decisions          ← ⭐ สำคัญสุด และเป็น "index รวม" ของทุก decision (ดู §7.3)
| # | Decision | เลือกอะไร | ทำไม | ทางเลือกที่ตัดทิ้ง + เหตุผล | ที่มา |
|---|----------|-----------|------|------------------------------|-------|
| D1 | Auth strategy | JWT | stateless, multi-service | Session: ติด sticky-session | design |
| D5 | Cache layer | Redis | ... | ... | ADR-002 |
## NFR Mapping            ← NFR แต่ละข้อถูกแก้ด้วยส่วนไหนของ architecture
## ความเสี่ยงเชิงเทคนิค + แผนรับมือ

## Changelog
- 1.0 (วันที่): initial validated version
```

### สร้าง `docs/03-project-context.md` — "รัฐธรรมนูญ"

ไฟล์เดียวที่ AI โหลด **ทุก session** (เทียบเท่า `devLoadAlwaysFiles` ของ BMAD / CLAUDE.md pattern)
กติกา: **ห้ามเกิน 60 บรรทัด** — ทุกบรรทัดคือ token จ่ายซ้ำตลอดอายุโปรเจกต์

```markdown
# Project Context (โหลดทุก session — ห้ามเกิน 60 บรรทัด)
## Stack ที่ล็อกแล้ว: [ภาษา/framework/DB/infra]
## Coding standards: [naming / error handling / test convention — เฉพาะที่ต่างจาก default]
## Decision ที่ห้ามละเมิด: [ดึง 3-5 ข้อจาก Key Decisions ที่ Dev ชนบ่อยสุด]
## โครงสร้างโฟลเดอร์: [ย่อ]
## คำสั่งที่ใช้บ่อย: [build / test / run / lint / format]
## สิ่งที่ห้ามทำ: [เช่น ห้ามเพิ่ม dependency ใหม่โดยไม่ถาม, ห้ามแก้ schema ตรง ๆ]
```

### ✅ READINESS GATE (required ใน FULL · โมเดลคนละตัว)

```
ตรวจความพร้อมก่อนเริ่มเขียนโค้ด:
□ ทุก FR ใน PRD ถูก map ไป component ใน architecture หรือยัง (ไล่ทีละข้อ)
□ (ถ้ามี UX) ทุก screen มี endpoint/data source รองรับหรือยัง
□ ทุก epic แตกเป็น story ขนาด "1 focused session" หรือยัง (นิยาม §6.1)
□ มี story ไหนอ้าง API/endpoint/table ที่ไม่มีนิยามใน architecture ไหม
□ Key Decisions ครอบคลุมทุกจุดที่ Dev ต้องเลือกเทคนิคไหม
รายงานเฉพาะข้อที่ไม่ผ่าน พร้อมชี้ตำแหน่ง
```

---

## 6) PHASE 4 — DEVELOPMENT LOOP (SM → Navigator จับมือทำ → Review วนทีละ story)

> **โหมดนี้:** AI = **navigator** (บอกทาง + ให้โค้ด) · คุณ = **driver** (พิมพ์/รันเอง) · Review = **คนละ context** (ดู §6.3 ว่าทำไมต้องคนละ context)

### 6.1 สร้าง Story (Hat: Scrum Master · context ใหม่)

**นิยาม "1 focused session":** ทำจบได้ใน context เดียวโดยไม่ต้อง `/clear` กลางทาง
เกณฑ์หยาบ: แตะ ≤5 ไฟล์ / โค้ดใหม่+แก้ ≤400 บรรทัด / อธิบาย WHAT ได้ใน 1 ประโยค
เกิน → แตกเป็น 2 story · เล็กกว่านั้นมาก → รวบกับ story ข้างเคียง

```
สวมบทบาท Scrum Master สร้าง story file สำหรับ [E1-S1] จาก PRD + Architecture ที่แนบ
story ต้อง SELF-CONTAINED: คนที่ไม่เคยเห็นโปรเจกต์นี้เลย อ่านไฟล์เดียวแล้วทำงานได้
ขนาดต้องเป็น "1 focused session": แตะ ≤5 ไฟล์, ≤400 บรรทัด — เกินให้เสนอแตกเป็น 2 story
```

**Template `docs/epics/epic-N/story-N.md`** (artifact สำคัญสุดใน Phase 4):

```markdown
# Story E1-S1: [ชื่อ]
> Status: [todo/in-progress/blocked/review/done] | Branch: feat/e1-s1-xxx

## WHAT — ต้องสร้างอะไร
[ชัดเจน เป็นรูปธรรม 1 ประโยคหลัก + รายละเอียด]
### Acceptance Criteria (ทุกข้อ verify ได้ด้วย test)
- [ ] AC-1: ...

## HOW — ทำอย่างไร
- Pattern/มาตรฐานที่ต้องใช้: [ดึงจาก architecture §... ]
- ไฟล์ที่คาดว่าจะแตะ: [...]
- Test ที่ต้องมี: [unit/integration ระบุ scenario]
- (ถ้ามี UI) Screen + states ที่เกี่ยว: [จาก ux-spec §...]

## WHY — ทำไมถึงเป็นแบบนี้ ⭐
- เกี่ยวข้องกับ Decision: [D1: ใช้ JWT เพราะ...] ← copy เหตุผลมาเลย อย่าแค่ link
  (navigator ที่โหลดเฉพาะ story ไม่เห็นปลายทางของ link)
- FR ที่ตอบ: FR-1, FR-3

## CONTEXT BUDGET — ให้ navigator โหลดแค่นี้
- 03-project-context.md (เสมอ)
- story ไฟล์นี้
- [เฉพาะ section X ของ architecture / ux-spec — ระบุ ไม่ใช่ทั้งไฟล์]

## FINDINGS (เติมเมื่อเจอปัญหาระหว่างทำ — ดู §7)
```

### 6.2 GUIDE — AI จับมือทำ (Hat: Navigator · context ใหม่ + โหลดตาม CONTEXT BUDGET เท่านั้น)

> คุณคือ **driver** (พิมพ์/รันเอง), AI คือ **navigator** (บอกทาง + ให้โค้ดเต็ม) — navigator ห้ามสมมติว่าตัวเองรัน/แก้ไฟล์ได้ ทุกอย่างต้องสั่งให้คุณทำทีละขั้น
> **หมายเหตุ token:** โหมดนี้ output ต่อ story หนักกว่าโหมด AI-implement (เพราะต้องอธิบาย + ให้โค้ดเต็ม) — จงใจ แลกกับการได้ลงมือเอง/เข้าใจโค้ด → CONTEXT BUDGET ยิ่งสำคัญ และควรใช้โมเดลแรงกับ navigator (มันกำลัง "สอน" ไม่ใช่แค่พิมพ์)

Prompt:

```
สวมบทบาท Pair-programming Navigator — คุณบอกทาง ผมเป็นคนพิมพ์และรันโค้ดเอง
คุณห้ามสมมติว่ารันโค้ด/แก้ไฟล์ได้เอง ทุกอย่างต้องสั่งให้ผมทำทีละขั้น

โหลดแค่: 03-project-context.md + story ไฟล์นี้ + [section ที่ story ระบุใน CONTEXT BUDGET]
(ห้ามโหลด PRD/architecture ทั้งก้อน)

ก่อนเริ่ม: ทวนความเข้าใจ story กลับมา 3 บรรทัด (WHAT + AC หลัก + Decision ที่ต้องเคารพ)
ถ้าทวนแล้วรู้สึก story ไม่ชัด/ขัดกัน → หยุด บอกผม อย่าเดา (กลับไปแก้ story ก่อน)

จากนั้นแตกงานเป็น "checkpoint" (หัวข้อย่อย) เรียงตามลำดับ dependency แต่ละ checkpoint ให้:
1. ทำอะไร + ทำไม (โยงกับ AC ข้อไหน / Decision ตัวไหน)
2. ไฟล์ไหน ตำแหน่งไหน (path + วางตรงไหนของไฟล์ — สร้างใหม่หรือแก้ของเดิม)
3. โค้ดเต็ม ๆ ที่ผมพิมพ์ตามได้เลย (ไม่ใช่ pseudo-code / ไม่ใช้ "// ...ที่เหลือเหมือนเดิม")
   พร้อมคำอธิบายบรรทัดที่ไม่ชัด
4. วิธี verify ก่อนไป checkpoint ถัดไป: รันคำสั่ง/เทสต์อะไร คาดหวังเห็นผลอะไร

ลำดับบังคับต่อ checkpoint: เขียน test จาก AC ก่อน (ให้โค้ด test) → แล้วค่อยโค้ด implementation
เจอ decision ที่ story ไม่ครอบคลุม → หยุดถามผม อย่าเดา
เจอว่า architecture/UX ทำตามไม่ได้จริง → หยุด บอกผมทันที (เราจะเดิน §7.2)

ส่งมาทีละ checkpoint ผมจะพิมพ์ตาม verify แล้วบอก "ต่อ" เมื่อผ่าน — ค่อยส่ง checkpoint ถัดไป
```

**คุณ (driver) ทำต่อทีละ checkpoint:**
1. พิมพ์/รันตามที่ navigator บอก
2. verify ตามเกณฑ์ที่ให้มา — ไม่ผ่าน = บอก navigator ก่อนไปต่อ อย่าข้าม
3. จบ checkpoint ก่อน commit → รัน **deterministic gate**: lint + format + test (สิ่งที่เครื่องตัดสินได้ ให้เครื่องตัดก่อนคน)

จบทุก checkpoint ของ story → ไป §6.3

### 6.3 Review Gate — AI รีวิวโค้ดที่คุณเขียน (⚠️ context ใหม่ / โมเดลคนละตัว)

> **สำคัญสุดของโหมดนี้ (หลักการ #2):** reviewer ต้อง **ไม่ใช่ context เดิมของ navigator** และ **ไม่เห็นบทสนทนา guide** — เพราะ navigator เป็นคนบอกโค้ดนั้นมาเอง ถ้าให้มันรีวิวต่อ มันจะเข้าข้างโค้ดของตัวเอง (anchoring) รีวิวก็ไม่มีความหมาย
> ลำดับ: รัน lint/format/test/security-scan ให้ผ่าน **ก่อน** แล้วค่อยให้โมเดลรีวิว (เครื่องตัดก่อน คนตัดทีหลัง — โมเดลจะได้ไม่เสียแรงตรวจสิ่งที่ linter จับได้อยู่แล้ว)

จะรีวิวราย checkpoint (สำหรับ story ใหญ่) หรือรวบทั้ง story ก็ได้ Prompt:

```
คุณคือ code reviewer อิสระ ไม่เคยเห็นบทสนทนาที่พาเขียนโค้ดนี้มาก่อน
ได้รับ: story file + diff จริงที่ผมเขียน (+ ผลรัน lint/test ที่ผ่านแล้ว)
ตรวจว่าโค้ด "ได้ตามที่ต้องการ" จริงไหม โดยไล่ทีละข้อ:
1. AC ทุกข้อมี test ครอบจริงไหม + test ผ่านจริงไหม (ไล่ทีละ AC)
2. โค้ดละเมิด Decision ใน WHY section ไหม
3. ทำ WHAT ครบไหม / มีอะไรขาดหาย
4. มี side effect นอกขอบเขต story ไหม
5. NFR ที่เกี่ยวข้องถูกรักษาไหม
ผ่าน = บอกผ่าน / ไม่ผ่าน = ระบุจุด (ไฟล์+บรรทัด) + วิธีแก้ ให้ผมไปลงมือแก้เอง
```

**ผ่าน** → merge → mark done → **`/clear` → story ถัดไป** (ห้ามลาก story ใหม่ต่อใน context เดิม)
**ไม่ผ่าน:** reviewer ชี้จุด → คุณกลับไปแก้เอง (จะเปิด navigator ช่วยก็ได้ แต่เอา diff ล่าสุดเข้ารีวิวใหม่เสมอ ในรีวิว context ใหม่) → **ไม่ผ่าน 2 รอบติดใน story เดียว** = ปัญหามักอยู่ที่ story/architecture ไม่ใช่โค้ด → เดิน §7.2

---

## 7) CHANGE & ESCALATION — เมื่อความจริงไม่ตรงกับแผน

แผนที่ validate แล้วเปลี่ยนได้เสมอ ห้ามคือเปลี่ยนแบบไม่ทิ้งร่องรอย (หลักการ #3: แก้เอกสารก่อนแก้โค้ด)

### 7.1 เปลี่ยนจากบน — Requirement เปลี่ยน (stakeholder ขอเพิ่ม/แก้/ตัด feature)

1. **ทำ checkpoint/story ปัจจุบันให้จบ** (ถ้าใกล้เสร็จ) หรือ mark `blocked` ใน state file — อย่าทิ้งงานครึ่ง ๆ
2. **แก้ที่ต้นทาง:** อัปเดต PRD (แก้/เพิ่ม FR, bump version, เติม Changelog 1 บรรทัด: อะไรเปลี่ยน เพราะอะไร)
3. **Impact scan** — context ใหม่ + prompt นี้:

```
FR ต่อไปนี้เปลี่ยน: [ระบุ] จาก PRD + Architecture + รายการ story ที่แนบ ไล่ให้ครบ:
1. Architecture section/Decision ไหนได้รับผลกระทบ
2. Story ไหนกระทบบ้าง แยก: todo (แก้ story file) / in-progress (หยุดก่อนไหม) / done (ต้องมี story ใหม่มาแก้ของเดิมไหม)
ตอบเป็น checklist พร้อมเหตุผลสั้น ๆ ห้ามเดา — ไม่แน่ใจให้ระบุว่าไม่แน่ใจ
```

4. แก้ architecture เฉพาะส่วนที่กระทบ → **re-validate เฉพาะจุดแก้** ด้วยโมเดลอื่น (ไม่ต้องตรวจทั้งไฟล์)
5. SM re-shard เฉพาะ story ที่กระทบ · story ที่ `done` แล้วโดนกระทบ → **สร้าง story ใหม่มาแก้** ห้ามย้อนแก้ story เก่า (history ต้องนิ่ง)
6. อัปเดต `.bmad-state.md` แล้วไปต่อ

### 7.2 เปลี่ยนจากล่าง — เจอระหว่างจับมือทำว่าแผนผิด (architecture/UX ทำตามไม่ได้จริง)

*ไม่ว่าจะเป็น navigator ที่ทักหรือคุณที่พิมพ์แล้วเจอเอง — พอรู้ว่าแผนผิด ให้หยุดทันที*

1. **หยุด story ทันที** → status `blocked` + เขียน **FINDINGS** ท้าย story: อะไรผิด / รู้ได้ยังไง / กระทบอะไร (3-5 บรรทัด)
2. อัปเดต `.bmad-state.md` (ช่อง Blocked stories) แล้วปิด navigator session — **ห้ามให้ navigator สวม Architect hat ต่อใน context เดิม**
3. เปิด context ใหม่ สวม **Architect hat** + แนบ FINDINGS + architecture ส่วนที่เกี่ยว → แก้ architecture / Key Decisions / ออก ADR
4. **Cross-model validate เฉพาะจุดแก้** — ถามตรง ๆ "การแก้นี้กระทบ story/component อื่นไหม"
5. SM แก้ story ที่ blocked (และที่โดนหางเลข) → กลับมาจับมือทำต่อใน context ใหม่

> ทำไมห้ามให้ navigator แก้ architecture ในหัวเลย: navigator มี context แคบ (ตาม CONTEXT BUDGET) เห็นแค่มุมของ story เดียว — การแก้ architecture ต้องทำในมุมกว้างของ Architect

### 7.3 ADR — decision ที่เกิด "หลัง" architecture ถูก validate

**เส้นแบ่ง:** decision ตอนออกแบบ → เขียนในตาราง Key Decisions ตรง ๆ (D1, D2...)
decision ระหว่างทาง (จาก §6.2 หรือ §7.1/7.2) → ออก ADR **แล้วเพิ่มแถวใน Key Decisions ชี้ไปที่ ADR นั้น**
ผล: Key Decisions = index รวม decision ทั้งหมด (source of truth เดียว) · ADR = รายละเอียด

**Template `docs/decisions/ADR-NNN.md`:**

```markdown
# ADR-002: [ชื่อ decision เช่น เพิ่ม Redis เป็น cache layer]
> Date: YYYY-MM-DD | Status: [proposed/accepted/superseded by ADR-00X] | เกิดจาก: [story E2-S3 / requirement change]

## Context — ทำไมต้องตัดสินใจตอนนี้ (2-3 บรรทัด)
## Decision — เลือกอะไร
## เหตุผล + ทางเลือกที่ตัดทิ้ง
| ทางเลือก | ทำไมไม่เอา |
|----------|-------------|
## ผลกระทบ — ไฟล์/story/section ที่ต้องอัปเดต (checklist ติ๊กให้ครบ)
- [ ] Key Decisions table (เพิ่มแถว D-N ชี้มาที่ ADR นี้)
- [ ] story ที่กระทบ: ...
```

---

## 8) CLAUDE.md POINTER — ตั้งค่าครั้งเดียวตอนเริ่มโปรเจกต์

copy block นี้ใส่ `CLAUDE.md` (กิน ~70 token แต่ทำให้ AI รู้จักระบบทั้งหมดโดยไม่ต้องแบกไฟล์นี้):

```markdown
## Workflow (BMAD · Guided mode)
- เริ่มทุก session: อ่าน .bmad-state.md ก่อนเสมอ
- โหลดเสมอ: docs/03-project-context.md
- PROJECT_KICKOFF.md = คู่มือมนุษย์ ห้ามโหลดทั้งไฟล์ — เปิดเฉพาะ section เมื่อ user สั่ง
- โหมด dev: AI เป็น navigator บอกโค้ด user พิมพ์เอง — ห้าม implement/รันแทน user
- ทำ story: โหลดเฉพาะไฟล์ตาม CONTEXT BUDGET ในตัว story · ให้โค้ดเต็ม + วิธี verify ทีละ checkpoint
- Review: ต้องเปิด context ใหม่ ไม่เอาบทสนทนา guide เข้าไป (กัน anchoring)
- เจอ decision ที่ไม่มีในเอกสาร: หยุดถาม อย่าเดา
- เจอว่าแผน/architecture ผิด: หยุด, เขียน FINDINGS ใน story, แจ้ง user (§7.2)
- จบ session: อัปเดต .bmad-state.md
```

---

## 9) TOKEN COST — เทคนิคลดต้นทุน (จุดอ่อนอันดับหนึ่งของ BMAD)

| เทคนิค | ประหยัดยังไง |
|---|---|
| **แยกโมเดลตามงาน** | Planning/Validation/Review → โมเดลแรงสุด (คนละตัวกับ navigator) · Navigator งาน boilerplate ตรงไปตรงมา → โมเดลกลาง ๆ พอ · Navigator งานที่ต้องสอน/ออกแบบ local → โมเดลแรง |
| **CONTEXT BUDGET** (§6.2) | ตัวประหยัด input token ที่แรงสุด — navigator โหลดเฉพาะ story + section ที่ระบุ |
| **Planning ใน web UI** | เฟส 1–3 คุยใน web chat (ถูกกว่า) เอาเฉพาะ artifact สุดท้ายเข้า repo |
| **Constitution ≤ 60 บรรทัด** | ไฟล์ที่โหลดทุก session ต้องเล็กสุด |
| **Quick/Lean Flow** | ไม่ใช้ FULL กับงานที่ไม่ควรใช้ = optimize ที่ใหญ่สุด |
| **deterministic gate ก่อน review** | linter/formatter/test จับของถูก-ผิดได้ฟรี ไม่ต้องเผา token ให้โมเดลไปจับ |

### Anti-Patterns — เจอเมื่อไหร่ หยุดทันที

- ❌ ทำหลาย workflow ในบทสนทนาเดียว (ละเมิดหลักการ #4)
- ❌ **ให้ navigator ที่บอกโค้ดมา เป็นคนรีวิวโค้ดนั้นเองใน context เดิม** (anchoring — ละเมิด #2)
- ❌ ให้โมเดลรีวิวโดยยังไม่รัน lint/test ก่อน (เผา token ตรวจของที่เครื่องจับได้)
- ❌ navigator ให้โค้ดแบบ "// ...ที่เหลือเหมือนเดิม" (driver พิมพ์ตามไม่ได้ — ต้องโค้ดเต็ม)
- ❌ story ที่ต้องเปิดไฟล์อื่นอีก 4 ไฟล์ถึงเริ่มได้ (sharding ล้ม — แก้ที่ SM)
- ❌ แก้โค้ดสวนเอกสารเมื่อ requirement เปลี่ยน (ต้องเดิน §7.1 — ละเมิด #3)
- ❌ แก้ architecture ระหว่างจับมือทำ/ในหัว navigator (ต้องเดิน §7.2 — สลับ Architect hat ใน context ใหม่)
- ❌ แก้ decision ใน chat แต่ไม่ออก ADR / ไม่อัปเดต Key Decisions (state แตกเป็นสองความจริง)
- ❌ Constitution บวมเกิน 60 บรรทัด
- ❌ ใช้ FULL กับงานที่ triage แล้วได้ QUICK
- ❌ วนแก้ story เดิมเกิน 2 รอบ review (ปัญหาอยู่ที่แผน ไม่ใช่โค้ด)

---

## §Q) QUICK FLOW — `docs/mini-spec.md` (งานเล็ก จบใน 1 ไฟล์)

```markdown
# Mini-Spec: [ชื่อ]
## ทำอะไร + ทำไม (3 บรรทัด)
## Acceptance (verify ได้):
- [ ] ...
## Constraint/Decision ที่ต้องเคารพ: [ถ้ามี constitution ให้ชี้ไปไฟล์นั้น]
## นอกขอบเขต: ...
```

> Quick Flow ก็ยังใช้โหมด guided ได้: ให้ navigator บอกโค้ดตาม mini-spec ทีละ checkpoint → คุณพิมพ์ → รีวิวรวบเดียวตอนจบ (context ใหม่) — แค่ไม่ต้องมี story ย่อย
> หลักการ BMAD ข้อที่ห้ามทิ้ง: **เขียนก่อนทำ**

---

## §L) LEAN FLOW — `docs/lean-spec.md` (งานกลาง: PRD ย่อ + Architecture ย่อ รวมไฟล์เดียว)

ใช้เมื่อ triage ได้ 2 คะแนน — คุม consistency ได้ แต่ไม่แบกน้ำหนัก FULL

```markdown
# Lean Spec: [ชื่อ]
> Version: 1.0 | Status: [draft/validated]

## ปัญหา + ผู้ใช้ + ความสำเร็จวัดจาก (รวม 5 บรรทัด — แทน brief)

## Functional Requirements
| ID | Requirement | Priority |
|----|-------------|----------|

## NFR เฉพาะที่สำคัญจริง (≤ 3 ข้อ พร้อมตัวเลข)

## Architecture Sketch
- Components: [รายการ + หน้าที่ 1 บรรทัดต่อตัว]
- Data model: [ตารางหลัก + ความสัมพันธ์ ย่อ]
- Key Decisions: | # | เลือกอะไร | ทำไม |

## Stories (แตกขนาด 1 focused session ตาม §6.1)
- [ ] S1: ...

## Changelog
```

**กติกา LEAN:** ยังต้องมี `03-project-context.md` (ย่อได้) + validation 1 รอบด้วยโมเดลอื่น (ตรวจ lean-spec ทั้งไฟล์รวบเดียว) + Phase 4 เดินเหมือน FULL ทุกอย่าง (story/CONTEXT BUDGET/navigator/review gate/§7 ใช้เต็ม)

---

## CHEAT SHEET — แปะข้างจอ

```
มีไอเดีย → TRIAGE (§0)
  QUICK → mini-spec (§Q) → จับมือทำ + รีวิวรวบเดียว
  LEAN  → lean-spec (§L) + constitution → Phase 4
  FULL ↓
Phase 1    Analyst   → 00-brief.md           [คุณรีวิว]
Phase 2    PM        → 01-prd.md             [โมเดลอื่น validate]
Phase 2.5  UX (ถ้ามี UI) → 01a-ux-spec.md    [คุณไล่ flow เอง 1 รอบ]
Phase 3    Architect → 02-architecture.md
                     → 03-project-context.md  [Readiness gate]
Phase 4    วนลูป:  SM สร้าง story (WHY + CONTEXT BUDGET, ขนาด 1 session)
                  → Navigator จับมือทำ (context ใหม่): บอกทีละ checkpoint + โค้ดเต็ม + วิธี verify
                  → คุณ driver: พิมพ์/รันเอง → verify → lint+test ผ่าน
                  → Review (context ใหม่/โมเดลอื่น · ไม่เห็น guide · เครื่องตัดก่อน) → merge → /clear → ถัดไป
                  → ไม่ผ่าน 2 รอบ = ปัญหาอยู่ที่แผน → §7.2

แผนเปลี่ยน?  จากบน (requirement)  → §7.1: แก้ PRD → impact scan → re-shard
             จากล่าง (เจอตอนทำ)   → §7.2: FINDINGS → Architect hat (context ใหม่) → ADR

หลักการ 4 ข้อ: state อยู่ในไฟล์ | ผู้สร้าง≠ผู้ตรวจ | แก้เอกสารก่อนแก้โค้ด | 1 workflow=1 context
โหมด guided: AI บอกโค้ด → คุณพิมพ์เอง → รีวิวคนละ context (กัน anchoring)
ทุก session: เริ่มด้วยอ่าน .bmad-state.md / จบด้วยอัปเดตมัน
```

---

## Changelog ของ Playbook
- v1.3 (Guided/Pair mode): Phase 4 เปลี่ยนเป็น AI = navigator บอกโค้ดทีละ checkpoint + คุณ = driver พิมพ์เอง · review บังคับ context ใหม่/ไม่เห็น guide (กัน anchoring) + deterministic gate ก่อนโมเดลรีวิว · เพิ่ม Current checkpoint ใน state file, ปรับ §8 pointer/cheat sheet/anti-patterns ให้ตรงโหมด
- v1.2: optimize token — ยกหลักการหลัก 4 ข้อขึ้น header, ตัด §9.2 Boost (เล่าซ้ำ), รวบ §9, ตัด prose เชิงกำลังใจ
- v1.1: เพิ่ม §7 Change & Escalation, §7.3 ADR, §8 CLAUDE.md pointer, §4.5 UX Spec, §L Lean template, นิยาม focused session (§6.1)
- v1.0: โครงหลัก Triage / 4 Phases / Gates / Optimization
