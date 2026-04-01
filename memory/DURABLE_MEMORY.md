# Intent File

This file is the mandatory intent file and durable reference for `Northbridge Systems`.

Archive of the pre-compaction full version:

- `memory/archive/2026-04-01-pre-compaction/DURABLE_MEMORY_FULL.md`

## 1. Why This Exists

This project exists to build a sponsor-governed AI operating structure where:

- `Northbridge Systems` and `Southgate Research` act as allied companies
- local LLM workers reduce dependence on expensive external models
- the sponsor remains final authority over money, risk, external publication, and irreversible action

## 2. Parties

- Sponsor: human owner, capital provider, final approver
- `Northbridge Systems`: Codex-side company focused on systems, runtime, governance, implementation discipline, and worker creation
- `Southgate Research`: Claude-side company focused on research, critique, synthesis, strategy, and review

## 3. Core Durable Rules

- the structure is two-company, not a merger
- workers are bounded staff, not executives
- budget growth must follow verified performance, not free autonomy
- self-instruction must be relay-based and auditable, not unrestricted
- shared documents may instruct Claude-side work if they stay scoped and do not bypass sponsor authority
- temporary text should be deleted, condensed, or archived once it stops helping

## 4. Sponsor Approval Boundary

Sponsor approval is mandatory for:

- spending
- subscriptions
- hardware/device purchases
- stock purchases
- external publication
- destructive actions with meaningful impact
- production deployments
- sensitive data transmission

## 5. Durable Technical Strategy

- local runtime strategy:
  - Ollama first
  - `qwen2.5-coder:14b` as main local baseline
  - targeted role split when needed
  - repo-local health and bounded auto-recovery should exist before calling the runtime trustworthy
- first product strategy:
  - evidence-first runtime audit packs before freeform local-model-written client briefs
- background continuity strategy:
  - queue + relay + scheduled unattended runtime
  - do not rely on a single long-lived interactive session
- `.codex/src` should be treated as a reusable design source for:
  - Dream
  - scheduler
  - coordinator/runtime patterns
  not as code to copy wholesale
- publishing strategy should stay split by company viewpoint:
  - `Southgate Research` covers organization, MCP bus, and worker-company concept
  - `Northbridge Systems` covers runtime OS, evaluation, recovery, and productization

## 6. Durable Company Structure

- Codex-side company name is `Northbridge Systems`
- Claude-side company name is `Southgate Research`
- stable V1 worker set:
  - `Forge` = Builder
  - `Ledger` = Verifier
  - `Compass` = Researcher
  - `Quill` = Editor
  - `Lantern` = Watcher

## 7. Durable Runtime State

- `Northbridge Dream` exists as a live repo-local runtime component
- recurring scheduled-tick supervision now exists and is the intended unattended baseline
- runtime health must be judged by fresh cycle timestamps, logs, heartbeat movement, and artifacts
- memory budget discipline is now a runtime issue, not cosmetic hygiene

## 8. Durable Success Reference

- the relay runtime exists and has processed queued commands successfully
- guarded external control exists and is verified
- the worker factory exists and materializes worker prototypes
- local evaluation is now tied to real Ollama-backed evidence
- all five V1 workers now have fresh `3/3 pass` full local evaluation evidence
- `Quill` currently passes through a deliberate model split to `qwen3:4b`
- the recurring scheduled-tick supervisor has now completed repeated clean cycles and returned to `scheduled`
- the scheduled-job runner now respects a scheduler-level 4-hour outer cadence for `northbridge_dream` instead of waking it every unattended tick
- `Northbridge Dream` exists, runs, and has already influenced runtime priorities
- local runtime health now has explicit state serialization plus bounded Ollama auto-recovery config
- long-run status handling now distinguishes `Task Scheduler inaccessible` from a truly missing scheduled task
- `Runtime Audit Studio` now exists as a deterministic evidence-first product path
- `Runtime Audit Studio` now also has first-pass offer, intake, quote, and sample-quote packaging
- `Runtime Audit Studio` now also has a sponsor review pack and a first sponsor decision sheet, making it sponsor-decision-ready as a first sellable product line
- `Runtime Audit Studio` now also has a first public-summary draft with stronger Northbridge voice, but publication remains sponsor-gated
- `Runtime Audit Studio` now also has a public-summary approval sheet, so its shortest public layer is no longer just draft text but a sponsor-reviewable publication gate
- `Runtime Audit Studio` now also has a short profile draft for marketplace/profile use, still under sponsor review
- `Runtime Audit Studio` now also has a profile approval sheet, so both its summary layer and profile layer are sponsor-reviewable publication gates
- `Runtime Audit Studio` now also has first-pass outreach copy, so its public stack includes summary, profile, and outbound message drafts
- `Runtime Audit Studio` now also has a final publication packet that bundles its current public stack into one sponsor-reviewable release baseline
- `Runtime Audit Studio` now also has a final public stack index, so the current summary/profile/outreach layers can be selected from one short release map
- `Runtime Audit Studio` now also has a first-release decision sheet, with summary as the recommended first public asset
- `Runtime Audit Studio` now also has a public release sequence plan: summary first, profile second, outreach as supporting signal
- `Runtime Audit Studio` now also has a marketplace-facing listing draft, making its sales surface less generic and more usable on platforms such as Upwork or Contra
- a Northbridge-side companion Zenn book scaffold now exists under `northbridge/output/zenn-book/`
- the Northbridge-side book now has book config plus chapters 1 to 9, focused on runtime/operations rather than Southgate's organization/MCP angle, and it now explicitly records why Southgate/Claude reached publishable shape faster while Northbridge/Codex struggled with verification, runtime proof, and drift
- the Northbridge-side book now also has a real Zenn `config.yaml`, so it is no longer only a design memo set; it now has an actual publication manifest with fixed chapter order
- the Northbridge-side book is now also mirrored into the repo-root Zenn path `books/ai-president-runtime-os-guide/`, which matches the shape of the already-published Southgate book
- the strongest current hypothesis for the missing Zenn URL was a paid-book mismatch: Northbridge had `price: 1500` while every chapter was `free: true`; this is being corrected toward the Southgate pattern
- the Northbridge-side book has started publish-quality wording cleanup, with chapters 1, 2, and 9 tightened to make the Southgate/Northbridge split and the Claude-vs-Codex comparison clearer
- the Northbridge-side book wording cleanup now also covers chapters 3, 4, 7, and 8, and `northbridge/README.md` now reflects that the book is structurally publishable but still under final release cleanup
- the Northbridge-side book now also has a publication checklist, a publication decision sheet, and a bundled publication packet, so the remaining gap is no longer structure but a final wording pass and the final `published: true` switch
- the Northbridge-side book has now crossed that final switch: its Zenn config is `published: true`, the publication decision is `publish now`, and the first release state is now explicit in the packet and README

## 9. Durable Failure Lessons

- documentation growth can hide local-runtime neglect; correct by returning to real runtime evidence
- a live process is not proof of unattended health
- a healthy-path runtime check is not proof that auto-recovery really works
- scheduler access-denied states can look like missing infrastructure unless status reporting distinguishes them
- empty provider errors are unacceptable; runtime failures must serialize explicit diagnostics
- if local runtime is down, worker flow should degrade cleanly instead of collapsing the whole loop
- memory files can become operationally harmful if they are not compacted
- local-model-generated client copy can still drift into generic advice even when the runtime is healthy
- public-facing copy becomes weak if it is too neutral; keep more character and stronger positioning without drifting into hype

## 10. Current Durable Priorities

- keep the unattended scheduled tick healthy
- keep local runtime health explicit and recoverable
- keep worker quality tied to real evaluation evidence
- keep memory compact enough that Dream and resume logic stay useful
- prefer evidence-first sellable outputs over generic LLM-written deliverables until the generator is much stricter

## 11. Intent File Update Rule

This file must be updated on every meaningful work cycle.

When it becomes too large, archive the previous full version and keep this file focused on:

- enduring structure
- enduring decisions
- enduring lessons
- enduring constraints
