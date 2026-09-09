# AlphaVoice Canonical Repo Manifest

> Recovered: 2026-09-08 | Purpose: prevent stale cross-context artifacts from entering the repo

| Repo path | Canonical state | Included in this ZIP | Verification |
|---|---|---:|---|
| `PROJECT_KICKOFF.md` | Guided / Pair Mode v1.3 | Yes | Current uploaded guided playbook |
| `docs/00-brief.md` | v1.0 validated | Yes | Validated 2026-08-31 |
| `docs/01-prd.md` | v1.0 validated | **No — exact raw copy required** | PRD gate PASS |
| `docs/01a-ux-spec.md` | v1.0 validated | **No — exact raw copy required** | Validated 2026-09-01 |
| `docs/02-architecture.md` | v0.2 VALIDATED | **No — exact raw copy required** | SHA `17cc14b24d8424a1d4e17d7ca7f6b756693945e38f11cda334fcb13c9ec7d278` |
| `docs/03-project-context.md` | VALIDATED | Yes | SHA `c0136a28a1d8504bd5b2fa6c2c156114c67aeaa704c851616e179c0ae1b50c0e` |
| `docs/reviews/prd-validation-final-result-v1.0.md` | PASS | Yes | All AV-01–AV-13 closed |
| `docs/reviews/architecture-readiness-targeted-recheck-result-v0.2.md` | TARGETED PASS | Yes | AV-ARCH-01–06 closed |
| `docs/epics/epic-0/EPIC-0-INDEX.md` | sharded/current | Yes | E0 dependency index |
| `docs/epics/epic-0/story-1.md` | todo / Story gate PASS | Yes | E0-S1 |
| `docs/epics/epic-0/story-2.md` | todo / Story gate PASS | Yes | E0-S2 |
| `docs/epics/epic-0/story-3.md` | todo / Story gate PASS | Yes | E0-S3 |
| `docs/epics/epic-0/story-4.md` | todo / Story gate PASS | Yes | E0-S4 |
| `PHASE3-FINAL-MANIFEST.md` | Phase 3 gate record | Yes | Hash authority |
| `.bmad-state.md` | required by BMAD, current AlphaVoice copy unknown | No | Do not use Monston state |

## Explicitly stale / excluded

- Architecture v0.1 or files whose header still says draft.
- `02-architecture-v0.2-remediated.md` with pre-final hash.
- Project Context pre-housekeeping hash `592444ab...`.
- `RECHECK-MANIFEST.md` that still describes pending targeted recheck.
- Generic `Pasted markdown.md` files.
