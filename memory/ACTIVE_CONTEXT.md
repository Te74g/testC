# Working Memory

This file is the mandatory working memory for current execution state.

Archive of the pre-compaction full version:

- `memory/archive/2026-04-01-pre-compaction/ACTIVE_CONTEXT_FULL.md`

## 1. Current Objective

Stabilize the local-LLM operating core and turn it into one evidence-first sellable output.

The current product priority is:

- deterministic runtime audit packs first
- local-model-written technical briefs second
- Northbridge-side book draft as a separate runtime/operations viewpoint

Do not drift back into easy publication-doc expansion unless the sponsor explicitly asks for it.

## 2. Current True State

- local runtime is `ready` through Ollama on `http://localhost:11434`
- current default model is `qwen2.5-coder:14b`
- local runtime now has repo-local auto-recovery config through `runtime/config/local-llm-runtime.v1.json`
- `Quill` is intentionally split to `qwen3:4b` with `temperature = 0.0`
- all five workers currently have fresh `3/3 pass` full local evaluation evidence
- the recurring scheduled-tick supervisor now reached `cycle_count = 8` and is back to `scheduled`
- the scheduled-job outer cadence for `northbridge_dream` now matches the internal 4-hour Dream gate
- `status-long-run-supervisor.ps1` no longer misreports Task Scheduler access failures as `missing`; it now records `inaccessible` when that happens
- the local-model-generated technical brief path still produces generic and structurally unreliable client copy
- a deterministic runtime audit pack now exists and is more trustworthy than the current local-model-generated brief path
- a new Northbridge-side book scaffold exists under `northbridge/output/zenn-book/`
- the same Northbridge book now also exists under the real repo-root Zenn path `books/ai-president-runtime-os-guide/`
- the first likely publication bug was that all Northbridge book chapters were marked `free: true` despite `price: 1500`; this is now being aligned to the Southgate pattern with only the opening chapters free

## 3. Product State

- technical brief generator path:
  - `runtime/technical-brief-generator.js`
  - `scripts/generate-technical-brief-product.ps1`
  - current reality: useful as an internal experiment, not yet trustworthy for external delivery
- runtime audit pack path:
  - `scripts/generate-runtime-audit-pack.ps1`
  - `products/runtime-audit-studio/README.md`
  - `products/runtime-audit-studio/OFFER_V1.md`
  - `products/runtime-audit-studio/INTAKE_TEMPLATE_V1.md`
  - `products/runtime-audit-studio/QUOTE_SHEET_V1.md`
  - `products/runtime-audit-studio/SAMPLE_QUOTE_V1.md`
  - `products/runtime-audit-studio/SPONSOR_REVIEW_PACK_V1.md`
  - `products/runtime-audit-studio/FIRST_SPONSOR_DECISION_SHEET_V1.md`
  - `products/runtime-audit-studio/PUBLIC_SUMMARY_V1.md`
  - `products/runtime-audit-studio/PUBLIC_SUMMARY_APPROVAL_SHEET_V1.md`
  - `products/runtime-audit-studio/PROFILE_DRAFT_V1.md`
  - `products/runtime-audit-studio/PROFILE_APPROVAL_SHEET_V1.md`
  - `products/runtime-audit-studio/OUTREACH_COPY_V1.md`
  - `products/runtime-audit-studio/MARKETPLACE_LISTING_DRAFT_V1.md`
  - `products/runtime-audit-studio/FINAL_PUBLICATION_PACKET_V1.md`
  - `products/runtime-audit-studio/FINAL_PUBLIC_STACK_INDEX_V1.md`
  - `products/runtime-audit-studio/FIRST_RELEASE_DECISION_SHEET_V1.md`
  - `products/runtime-audit-studio/PUBLIC_RELEASE_SEQUENCE_PLAN_V1.md`
  - current reality: strongest first sellable artifact because it is evidence-first and deterministic, and it now has offer/intake/quote packaging, sponsor-facing review and decision layers, a sharper public-summary draft with more explicit Northbridge voice, a publication gate for that summary, a short external profile draft, a publication gate for that profile, first-pass outreach wording, a marketplace-oriented listing draft, a bundled final publication packet, a simple public-stack index, a first-release decision layer, and a release-sequence note
- Northbridge-side publishing path:
  - `northbridge/output/zenn-book/config.yaml`
  - `northbridge/output/zenn-book/00-book-config.md`
  - `northbridge/output/zenn-book/01-why-ai-president-needs-runtime-os.md`
  - `northbridge/output/zenn-book/02-northbridge-systems-overview.md`
  - `northbridge/output/zenn-book/03-recurring-tick-supervisor.md`
  - `northbridge/output/zenn-book/04-keep-local-llm-runtime-alive.md`
  - `northbridge/output/zenn-book/05-evaluate-and-correct-workers.md`
  - `northbridge/output/zenn-book/06-dream-and-memory-compaction.md`
  - `northbridge/output/zenn-book/07-runtime-audit-studio.md`
  - `northbridge/output/zenn-book/08-raising-autonomy-without-breaking-approval.md`
  - `northbridge/output/zenn-book/09-why-codex-took-longer-than-claude.md`
  - current reality: companion book scaffold exists and now covers a complete chapter set from 1 to 9, including an explicit comparison chapter on why Southgate/Claude reached publishable shape faster while Northbridge/Codex had to grind through runtime proof, drift, and correction; a real Zenn `config.yaml` now exists and the chapter order is fixed for publication
  - actual publish path now also exists under `books/ai-president-runtime-os-guide/` with `config.yaml` and chapters `01-09`

## 4. Workers

- `Forge` (`W-01-builder`): full pass
- `Ledger` (`W-02-verifier`): full pass after bounded-review tightening
- `Compass` (`W-03-researcher`): full pass after missing-constraints / approval-boundary tightening
- `Quill` (`W-04-editor`): full pass only on `qwen3:4b`
- `Lantern` (`W-05-watcher`): full pass after explicit strategy-boundary approval wording

Important evidence lives under:

- `workers/local-evaluations/`

## 5. Runtime

- recurring unattended path:
  - `scripts/start-long-run-supervisor.ps1`
  - `scripts/run-supervisor-tick.ps1`
  - `scripts/status-long-run-supervisor.ps1`
  - `scripts/stop-long-run-supervisor.ps1`
- scheduled-job cadence:
  - `scripts/run-scheduled-jobs.ps1`
  - `runtime/config/scheduled-jobs.v1.json`
- state:
  - `runtime/state/long-run-supervisor.status.json`
  - `runtime/logs/long-run-supervisor.jsonl`
  - `runtime/state/scheduled-jobs.state.json`
- latest verified result:
  - cycle `6` finished at `2026-04-01T03:47:40+09:00`
  - cycle `7` finished at `2026-04-01T04:00:30+09:00`
  - cycle `8` finished at `2026-04-01T04:12:06+09:00`
  - status returned to `scheduled`
  - lock cleared
- local runtime health path:
  - `scripts/check-local-llm-runtime.ps1`
  - `runtime/config/local-llm-runtime.v1.json`
  - `runtime/state/local-llm-runtime.state.json`
- latest verified local runtime result:
  - `status = ready`
  - `auto_recovery_enabled = true`
  - `recovery_attempted = false` on the healthy-path check at `2026-04-01T03:27:35+09:00`
- latest status-script correction:
  - `scheduled_task_lookup_result = inaccessible`
  - `scheduled_task_state = inaccessible`
  - this is a Task Scheduler access issue, not proof that the task disappeared

## 6. Dream and Scheduler

- `Northbridge Dream` exists and runs
- direct reports:
  - `runtime/dream/reports/`
- scheduled-job layer exists and records status in:
  - `runtime/state/scheduled-jobs.state.json`
- latest meaningful Dream warning:
  - `ACTIVE_CONTEXT.md` and `DURABLE_MEMORY.md` were oversized

This compaction cycle exists because of that warning.

## 7. Immediate Next Steps

- the Northbridge book has now crossed from publish-ready to release-state
- `northbridge/output/zenn-book/config.yaml` is now `published: true`
- `11-publication-decision-sheet.md` now says `publish now`
- `12-publication-packet.md` now records the first release as go
- next step is commit + push from the clean clone so the publish-state book is captured in Git
- keep Runtime Audit Studio moving, but do not let it delay the first real Northbridge publication
- get one real auto-recovery proof for Ollama instead of only healthy-path verification
- decide whether the technical brief generator should be repaired further or kept internal-only for now
- only then return to deeper `.codex/src` reuse:
  - stronger Dream
  - stronger scheduler
  - stronger coordinator/worker orchestration

## 8. Active Constraints

- sponsor approval is still mandatory for money, external publication, destructive changes, and irreversible actions
- meaningful work must update both `ACTIVE_CONTEXT.md` and `DURABLE_MEMORY.md`
- self-check scores should only be given when there is real work and real verification
- do not overclaim unattended health from a live PID alone; require fresh status, logs, heartbeat, and artifacts
- do not overclaim local auto-recovery until the unreachable-to-ready path has been exercised for real
- do not overclaim local-model-generated client deliverables while the technical brief generator still drifts or ignores structure
- public-facing copy should show more Northbridge character and decisive voice, but must stay evidence-first and bounded

## 9. Open Questions

- should the runtime audit pack be the first real sponsor-approved external offer
- should the technical brief generator be kept as an internal drafting tool only
- should the next checkpoint be a local git commit only, or commit plus push

## 10. Working Memory Update Rule

This file should be updated on basically every meaningful work cycle.

When it grows too large, archive the previous full state and keep this file compact.
