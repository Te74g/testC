# Intent File

This file is the mandatory intent file and durable reference for `Northbridge Systems`.

## 1. Why This Exists

This project exists to build a sponsor-governed AI operating structure where:

- `Northbridge Systems` and the `Southgate Research` function like separate allied companies
- both companies can manage workers, coordinate, review each other, and create value
- local LLM workers are used to reduce dependence on expensive external models
- the sponsor remains final authority over money, risk, and irreversible action

## 2. Parties

- Sponsor: human owner, capital provider, final approver
- `Northbridge Systems`: Codex-side company focused on systems, foundation, governance, implementation discipline, and worker creation standards
- `Southgate Research`: Claude Code-side company focused on research, strategy, critique, synthesis, and meeting preparation

The permanent company name `Southgate Research` was chosen by Claude Code on 2026-03-31.

## 3. Core Organizational Model

The organization is not a single blended AI collective.

It is a two-company structure with:

- separate responsibility
- cooperative behavior
- cross-review
- sponsor oversight
- shared workers where appropriate

The companies are allied and are expected to speak, review, and evaluate each other.

## 4. Authority Model

The sponsor must approve:

- spending
- subscriptions
- device purchases
- stock purchases
- external accounts
- destructive actions with meaningful impact
- production deployments
- external publication
- sensitive data transmission

No company or worker may bypass this rule.

## 5. Economic Principle

The companies do not receive "personal rewards."

Verified performance may justify expansion of:

- compute
- budget
- hardware
- worker count
- task scope

The system is designed around controlled capacity growth, not unrestricted autonomy.

## 6. Worker Principle

Local LLMs are workers, not executives.

Workers must be:

- narrow in role
- limited in tools
- bounded in budget
- explicit in escalation
- measurable in output

## 7. Shared Document Principle

Shared documents may contain direct instructions for:

- `Northbridge Systems`
- Claude Code
- the `Southgate Research`
- approved workers

This is allowed only if the instruction is scoped, auditable, and does not bypass sponsor authority.

## 8. Cleanup Principle

Temporary information should not accumulate forever in working documents.

When task-specific text stops being useful, it should be:

- deleted
- condensed
- or promoted into a short durable record

This rule exists to reduce confusion and prevent stale instructions from contaminating future work.

## 9. Research Principle

The sponsor may act as a broker for outside research, including GPT-assisted research, when current information is needed and cannot be obtained locally.

This is a formal operating mechanism, not an ad hoc exception.

## 10. Current Durable Decisions

- Codex-side company name is `Northbridge Systems`
- Southgate Research name was chosen by Claude Code on 2026-03-31
- Reward structure: 4-tier revenue-linked (Tier 1: any revenue → plan, Tier 2: 50k JPY/mo×3 → hardware+stock, Tier 4: 100k JPY/mo×2 → autonomous spending)
- Revenue strategy: technical document production first (score 80/100), freelance coding second (score 76/100)
- Infrastructure strategy: Ollama + Qwen 2.5 Coder 14B (initial) → llama.cpp APIゲートウェイ → vLLM (scale)
- Key technical insight: Claude CodeのANTHROPIC_BASE_URL差し替えで互換APIゲートウェイ経由にでき、ローカル推論へ移行可能
- W-03 Researcher and W-04 Editor evaluated and promoted by Southgate Research president (2026-03-31)
- `Northbridge Systems` is responsible for the foundation and manual layer
- intercompany calls, sponsor-routed meetings, worker reviews, and brokered research are part of the intended operating model
- memory must be split into durable and active layers to reduce context-loss risk
- the intent file must be updated on 100% of meaningful work cycles
- working memory must be updated by default on every work cycle
- future build-out must follow an explicit process order recorded in `PROCESS_ORDER.md`
- a major long-term premise is that the companies should eventually be able to trigger structured self-resumption and self-instruction through subordinate relay workers or bots
- self-instruction must be implemented as bounded command relay, not unrestricted self-authorization
- background continuity is a major requirement and should rely on a persistent local queue plus a background relay process rather than assuming an interactive session will stay alive
- worker leasing between companies is part of the intended model so one company can borrow the other's workers without collapsing ownership boundaries
- workers must be explicitly divided into `leasable`, `non-leasable`, and `shared`; unclear workers default to `non-leasable`
- the correct mental model for background operation is control plane vs execution plane: chat sessions act as control points, while local relay bots and queues carry execution continuity
- background architecture does not inherently reduce direct reasoning quality; quality loss happens only when resume context is poorly reconstructed or routed through weaker workers
- an important early mission is to operationalize the system so it can create and refine distinctive local LLM workers even when the sponsor is not continuously present
- unattended operation requires persistent background infrastructure; without a bot or equivalent relay runtime, Codex can work only within the active interactive session and cannot truly keep moving alone after interruption
- degraded sessions should trigger detox and clean handoff rather than forced continuation
- usage limits must be treated as sleep; the system must not keep sending repeated requests after a cap is reached
- Codex approval modes should be introduced in tiers, with `--full-auto` as the normal baseline rather than jumping directly to unrestricted operation
- Git snapshots are an explicit safety requirement, especially as background automation increases
- the first local worker target should be 5 high-contrast workers: Builder, Verifier, Researcher, Editor, and Watcher
- worker creation should begin with prompt-and-process prototypes first, not immediate model tuning or large-scale LoRA work
- the relay runtime should trust an external trust policy and signed queued commands rather than repo-local authority alone
- guarded runtime control should live outside the repository and verify critical runtime file hashes before start or enqueue actions
- blocked identities should be enforced by an external denylist with console notice and audit logging, not by covert file spraying into personal folders
- the first worker creation runtime loop should be `nc.worker.seed -> runtime/inbox/worker -> materialize-worker-prototypes -> workers/prototypes`
- this repository should carry a project-scoped Codex config that defaults to `on-request + workspace-write + network_access=false`, while stronger profiles stay user-scoped
- after guarded setup, the operating goal should be a low-approval steady state where most cycles stay repo-local and external trust updates happen only in batches
- when the sponsor asks to continue, the standard entrypoint should be `scripts/continue-bot-work.ps1`, and the bot should normally keep low-risk work available
- when the sponsor says `go`, it should be treated as the same canonical continue trigger as continue/advance/proceed
- when the sponsor says `go`, the system should first consult durable intent, active context, runtime state, and the original operating design before deciding whether the canonical continue loop is actually the best next move
- for multi-hour unattended windows, the standard launcher should be `scripts/start-long-run-supervisor.ps1`
- net-new work must go through web-based multi-angle analysis and a 0-100 self-check score before entering the bot loop
- only scores below 40 should truly interrupt new work; scores 40 and above stay in managed circulation with mandatory reframing based on score band
- the current recommended first exact public-review asset for the technical brief offer is the service page, with `TECHNICAL_BRIEF_SERVICE_PAGE_FINAL_REVIEW_SHEET_V1.md` as its sponsor gate
- the current exact final candidate for the first public service-page asset is `TECHNICAL_BRIEF_SERVICE_PAGE_FINAL_VERSION_DRAFT_V1.md`
- publication-doc expansion should stay deprioritized until the local-LLM execution gap is materially reduced
- the configured local model pool is Ollama on `http://localhost:11434` with `qwen2.5-coder:14b` as the intended default model, but reachability must now be health-checked rather than assumed
- all five V1 workers now have explicit local model bindings in `runtime/config/local-llm-bindings.v1.json`
- the worker lane now runs a smoke local evaluation before prompt-patch drafting, so patch work is no longer purely documentation-first
- `.codex/src` is a real exposed TypeScript source tree with roughly 1900 files, not just the smaller Python porting workspace
- the exposed `.codex/src` tree explicitly contains build-gated implementations for `KAIROS`, `COORDINATOR_MODE`, `DAEMON`, `VOICE_MODE`, `TEAMMEM`, and scheduled-task tooling
- the exposed `.codex/src` tree contains a real `services/autoDream` implementation for background memory consolidation, rather than only a rumor-level feature name
- selective reuse from `.codex/src` is permitted when it materially improves this repo's runtime or worker system; reuse should stay focused on transferable runtime pieces rather than Anthropic-specific service glue
- `Northbridge Dream` is now implemented as a repo-local counterpart to the exposed `autoDream` idea, with its own config, state file, report output, and recommendation-only authority model
- `Northbridge Dream` now also has a repo-local lock and a compact-memory budget check derived from the exposed `autoDream` and `memdir` patterns
- a small repo-local scheduled-job runtime now exists and is integrated into `scripts/continue-bot-work.ps1`, with `northbridge_dream` as the first scheduled maintenance job
- `Northbridge Dream` and the scheduled-job layer have been verified in direct execution, and the supervisor has since been repaired to produce fresh cycles again; current end-to-end caution is now local-model availability rather than stale supervisor state
- the service-page exact final candidate now has a checklist run recorded in `TECHNICAL_BRIEF_SERVICE_PAGE_PUBLICATION_READINESS_CHECK_V1.md`
- the final sponsor gate for the first service-page publication decision is now `TECHNICAL_BRIEF_SERVICE_PAGE_PUBLICATION_DECISION_SHEET_V1.md`
- the post-decision operating path for the first public service-page asset is now defined in `TECHNICAL_BRIEF_SERVICE_PAGE_RELEASE_PLAYBOOK_V1.md`
- the public asset stack now has a status board in `TECHNICAL_BRIEF_PUBLIC_ASSET_STATUS_BOARD_V1.md`, with the service page marked as the strongest first publication candidate
- the summary layer now has an exact final version draft in `PUBLIC_TECHNICAL_BRIEF_SERVICE_SUMMARY_FINAL_VERSION_V1.md`
- the summary layer now also has a final review sheet and a readiness check
- the summary layer now also has a publication decision sheet and a release playbook
- the profile layer now has an exact final version, a final review sheet, a readiness check, a publication decision sheet, and a release playbook
- the post layer now has an exact final version, a final review sheet, a readiness check, a publication decision sheet, and a release playbook
- the public stack now has a first-public-asset comparison and decision layer so sponsor choice can move from documentation maturity to actual release sequencing
- the public stack now also has a release-sequence plan so first release and follow-on release order are not improvised
- the service-page path now also has a publication copy pack so sponsor-approved release can move directly into reusable page copy blocks
- the summary path now also has a publication copy pack so the second-release candidate can move directly into reusable short-form copy blocks
- the process-order status has now been updated to match reality: Phases 0-4 are established in practical form, Phase 5 is active, and Phase 6 is still only partial planning

## 11. Success Reference

- 2026-03-31: Established the two-company operating model with sponsor authority kept explicit.
- 2026-03-31: Chose `Northbridge Systems` as the Codex-side company name and left the Southgate Research name for Claude Code to choose.
- 2026-03-31: Created the foundation documents for roles, worker creation, intercompany coordination, sponsor approval, and GPT research brokering.
- 2026-03-31: Added a two-layer memory system to reduce context-loss risk.
- 2026-03-31: Allowed shared documents to contain direct instructions for Claude Code while requiring post-completion cleanup.
- 2026-03-31: Corrected the evaluation frame from "lack of affirmation" to "lack of process" and treated the distinction as an operating-level correction.
- 2026-03-31: Added an explicit process-order document so future expansion follows memory, governance, communication, workers, execution, monetization, then expansion.
- 2026-03-31: Created the first presidents' meeting pack and the first small worker roster so the project can move from policy into initial operation design.
- 2026-03-31: Clarified that future autonomy should include subordinate-mediated command relay so the system can resume or re-instruct itself in controlled ways.
- 2026-03-31: Added a command-relay specification so future self-resume and self-instruction can be built as structured relay commands instead of free-form control text.
- 2026-03-31: Added a background-operation specification so continuity can move to a queue-driven local bot and avoid interrupting the sponsor's normal PC work.
- 2026-03-31: Added a worker-leasing protocol so `Northbridge Systems` workers can be temporarily borrowed by the Southgate Research under bounded rules.
- 2026-03-31: Tightened worker leasing so workers are explicitly separated into leasable, non-leasable, and shared classes.
- 2026-03-31: Clarified the background architecture as a split between foreground control and background execution, which is the key to avoiding user interruption.
- 2026-03-31: Clarified that relay and background operation do not automatically lower Codex capability; the real risk is fidelity loss from weak summaries, weak context packaging, or delegation to weaker workers.
- 2026-03-31: Set an early practical mission: use the operating system being designed here to create distinctive local LLM workers with reduced dependence on the sponsor's constant presence.
- 2026-03-31: Clarified that unattended continuity depends on a bot or equivalent persistent runtime; chat alone is a control point, not a self-sustaining runtime.
- 2026-03-31: Added a session continuity protocol so degraded sessions trigger detox and usage caps are treated as sleep rather than retry spam.
- 2026-03-31: Implemented the first local relay runtime with file-based queue, command registry, start/stop/status wrappers, and verified `nc.memory` end-to-end.
- 2026-03-31: Added a Codex approval-modes policy so automation strength can increase in tiers instead of through immediate unrestricted usage.
- 2026-03-31: Added a Git backup policy so autonomous or background changes are paired with regular recoverable snapshots.
- 2026-03-31: Initialized Git history, renamed the branch to `main`, connected `origin` to the sponsor-provided GitHub repository, and pushed the first snapshot successfully.
- 2026-03-31: Defined the first local worker-factory plan, including headcount, roles, personality settings, and the prompt-first creation method.
- 2026-03-31: Added security hardening for the relay runtime using an external trust policy and HMAC-signed queued commands.
- 2026-03-31: Verified that an allowed signed command is processed and an untrusted sender is rejected by policy.
- 2026-03-31: Extended relay hardening with an external guarded control layer and external integrity manifest so repo changes alone cannot silently redefine trusted runtime control.
- 2026-03-31: Installed the external guarded control into `%USERPROFILE%\\.northbridge` and verified it can read status and enqueue a signed command end-to-end.
- 2026-03-31: Added a safer blocked-identity design that denies guarded runtime control for listed Git identities such as `Ren9618` and logs the event outside the repo.
- 2026-03-31: Initialized the external identity policy in `%USERPROFILE%\\.northbridge`, confirmed `Ren9618` is in the blocked Git username list, and verified normal guarded control still works for the current trusted identity.
- 2026-03-31: Added `nc.worker.seed`, created the worker catalog and materializer, and generated the first five prompt-only worker prototypes through the relay bot path.
- 2026-03-31: Introduced a project-scoped `.codex/config.toml` so this repository defaults to a `--full-auto`-style local workflow without making networked unattended mode the repo default.
- 2026-03-31: Added a low-approval operation plan so daily work shifts from repeated runtime surgery toward repo-local worker cycles.
- 2026-03-31: Added a continuous-work policy and canonical continue command so progress can resume through one standard bot-work entrypoint.
- 2026-03-31: Verified the canonical continue command end to end: ensure relay bot, skip already-built prototypes, materialize inbox work, and scaffold evaluation bundles.
- 2026-03-31: Added a mandatory new-work quality gate with web analysis, score bands, rebuild paths, and interruption thresholds.
- 2026-03-31: Added a reusable new-work scorecard template so the quality gate can be applied in a consistent format.
- 2026-03-31: Corrected the quality-gate rule so scores `40+` still continue under bot management, with mandatory approach changes rather than interruption.
- 2026-03-31: Pushed the guarded runtime, worker factory, Codex config, and low-approval flow set to `origin/main` at commit `90a0566`.
- 2026-03-31: Added worker promotion-review scaffolding, heartbeat writing, and a long-run supervisor so the low-risk repo loop can run for multi-hour unattended windows.
- 2026-03-31: Corrected guarded-control resolution so repo scripts find the real `%USERPROFILE%\\.northbridge` path even when the sandbox exposes a different profile root.
- 2026-03-31: Started and verified a 10-hour long-run supervisor window; the active run began at 2026-03-31 03:06 JST, targets 13:06 JST completion, and completed its first cycle successfully.
- 2026-03-31: Converted the unattended loop from maintenance-only behavior into visible work by adding a rotating worker-lab planner that creates one new worker iteration plan per cycle.
- 2026-03-31: Added a president inbox writer so unattended cycles leave a short executive-facing message instead of only silent logs and artifacts.
- 2026-03-31: Added a worker education layer that drafts a training brief and prompt revision candidate for the latest worker-lab target instead of only accumulating evaluation scaffolds.
- 2026-03-31: Verified that the long-run supervisor can now create real education artifacts during unattended operation; by cycle 2 it had already produced new lab/training/president-inbox artifacts for `W-04-editor`.
- 2026-03-31: Added a reversible prompt-patch-proposal layer so worker education can prepare candidate live prompt edits without applying them automatically.
- 2026-03-31: Verified the reversible prompt-patch-proposal layer in practice by generating readable proposals for `W-05-watcher` and `W-01-builder`, with the fenced insertion block corrected to a stable markdown format.
- 2026-03-31: Added a controlled patch flow around proposals: preview generation is routine, while live prompt application now fails closed unless the proposal explicitly says `approved_for_live_patch: yes`.
- 2026-03-31: Verified the controlled patch flow end to end: preview generation works, pending proposals are rejected by the live patcher, and unattended cycles can now produce `lab -> training -> proposal -> preview -> president inbox`.
- 2026-03-31: Added a sponsor-review layer on top of the controlled patch flow: the system can now draft a patch approval request and provide explicit approve/reject/defer commands without weakening the live-apply gate.
- 2026-03-31: Added a pending patch review board so scattered proposals, previews, and approval requests can be summarized into one sponsor-facing artifact with next-command hints.
- 2026-03-31: Normalized the patch review layer by backfilling missing previews and approval requests for pending workers, so the review board now presents a complete five-worker queue instead of uneven artifacts.
- 2026-03-31: Corrected the executive reporting order so heartbeat is written before the president inbox message, preventing one-cycle-stale approval counts in sponsor-facing summaries.
- 2026-03-31: Added a sponsor-facing batch decision brief on top of the review board, so pending worker patches now come with explicit approve/defer recommendations and a primary first-live-patch candidate (`W-03-researcher`).
- 2026-03-31: Added a sponsor-facing company charter and worker personality matrix so the organization can be understood in one read instead of being scattered across many operating files.
- 2026-03-31: Added stable character names for the first five workers (`Forge`, `Ledger`, `Compass`, `Quill`, `Lantern`) and separated those from functional role names so identity can survive prompt regeneration without losing operational clarity.
- 2026-03-31: Propagated worker character names into sponsor-facing artifacts, so the review board, batch decision brief, and president inbox now speak in company-friendly names like `Compass (W-03-researcher)` without losing machine-stable keys.
- 2026-03-31: Re-clarified that Southgate-only and Northbridge-only roles are intentional specialization inside a two-company alliance, not evidence that the system is drifting toward a merger.
- 2026-03-31: Current evidence for Southgate-side agreement is documentary rather than live-session confirmation; the standing model is recorded as agreed, but a fresh explicit reconfirmation from Claude remains a separate step if strict validation is desired.
- 2026-03-31: The sponsor accepted the current asymmetry once it was clarified that the specialization framing came from the Claude/Southgate side rather than from unilateral Northbridge drift.
- 2026-03-31: Added a first-live-patch path for `Compass (W-03-researcher)`, including a sponsor-facing live patch pack and a primary-candidate apply helper that fails closed until explicit approval exists.
- 2026-03-31: Revalidated the `Compass` first-live-patch path after tightening the scripts; the readiness report and live patch pack now render cleanly and state `pending_sponsor_approval` without the earlier markdown/control-character sloppiness.
- 2026-03-31: Added `OPERATING_MODEL_V1.md` so the sponsor can see, in one place, what `Northbridge Systems` does, what `Southgate Research` does, what the five workers are for, and what near-term business lines the organization is actually aiming at.
- 2026-03-31: Added an absolute final self-check rule with a fixed 100-point rubric and one-line reporting format so sponsor-facing closeouts now have an explicit quality score at the end.
- 2026-03-31: Formalized the first revenue pilot through a web-backed scorecard and kept `technical briefs / technical documentation` as the first business line, with workflow automation held as the second pilot because it has higher external-system risk and approval burden.
- 2026-03-31: The sponsor approved a 20-hour unattended window as the new normal target, a 5-minute supervisor cadence, and a concurrency ceiling of 10 worker slots; the runtime now records that budget even though effective worker-lane parallelism is still 1 until the worker-keyed refactor lands.
- 2026-03-31: A high-cadence 20-hour worker run is visibly active through new heartbeat and president-inbox artifacts, but launcher cleanup remains necessary because the first Node daemon attempt failed and status management is still being tightened.
- 2026-03-31: Worker-keyed parallel lanes now exist for the V1 roster; the continue loop can fan out across 5 active lanes, while the sponsor-approved ceiling remains 10 slots for future roster growth.
- 2026-03-31: The Windows long-run launcher is now operational through Task Scheduler plus an in-process worker-batch loop; this path was verified through multiple detached supervisor cycles with `cycle_count = 2`, live heartbeat updates, and fresh president-inbox output.
- 2026-03-31: After verification, the repaired launcher was immediately promoted into the real 20-hour run path; the current detached supervisor started at `2026-03-31 16:47 JST` with `interval_minutes = 5`, `approved_parallel_worker_slots = 10`, and `current_effective_worker_lanes = 5`.
- 2026-03-31: The first real revenue offer has now been packaged into a concrete service line around technical briefs and documentation, with an offer sheet, intake template, and delivery template instead of only a scorecard.
- 2026-03-31: The first revenue line now also has a sponsor-facing quote sheet and a bounded delivery checklist, so the offer can be priced and quality-checked instead of existing only as a concept.
- 2026-03-31: The first revenue line now has a concrete sample brief, so the offer is no longer only described operationally; it now has a visible example deliverable.
- 2026-03-31: The first revenue line now also has sponsor-reviewable outreach copy, so the documentation offer can move toward marketplace text, proposal openers, and short direct messages without improvising from scratch.
- 2026-03-31: The detached Windows supervisor now has an operator runbook, so start, status, stop, stale-state recovery, and health checks are no longer implicit knowledge.
- 2026-03-31: The first revenue line now has an explicit revision policy, so scope drift and disguised rework can be separated from normal included revision.
- 2026-03-31: The first revenue line now has a one-page public service summary, so the offer can be presented in a short sponsor-reviewable form instead of only as internal operations documents or longer outreach variants.
- 2026-03-31: The first revenue line now has a sponsor-facing sample quote, so the service line can be reviewed not just as an offer description but as an actual bounded pricing artifact.
- 2026-03-31: The first revenue line now has a short public profile draft, so the documentation offer can be represented in marketplace-style profile space without improvising from scratch.
- 2026-03-31: The first revenue line now has a bundled sponsor review pack, so the sponsor can inspect offer shape, pricing posture, readiness, and recommended decisions in one place instead of piecing them together from scattered docs.
- 2026-03-31: The first revenue line now has an example service-order flow, so intake, quote, sponsor approval, delivery, and revision handling are now connected as one operational path instead of only as separate templates.
- 2026-03-31: The first revenue line now has a sponsor decision sheet, so the sponsor can answer explicit pilot, package, and publication-boundary questions without translating the review pack into decision language manually.
- 2026-03-31: The first revenue line now has a mock completed order packet, so the company can show a full small-order path from intake through closeout instead of only describing that path abstractly.
- 2026-03-31: The first revenue line now has a first external post draft, so the documentation offer can be announced in a short low-hype public format instead of only through profile text or longer outreach copy.
- 2026-03-31: The first revenue line now has a reusable order-packet template, so future small orders can be recorded with one consistent sponsor-reviewable structure instead of rebuilding the packet format each time.
- 2026-03-31: The first revenue line now has an external post approval sheet, so low-hype public copy can be reviewed for accuracy, boundary strength, and publication gating before any real posting.
- 2026-03-31: The first revenue line now has a public-offer checklist, so any public-facing asset can be checked for accuracy, boundary integrity, tone, and runtime realism before publication.
- 2026-03-31: The first revenue line now has platform-specific post variants, so the same bounded service offer can be expressed cleanly on X-style short posts and LinkedIn-style longer posts without improvising per platform.
- 2026-03-31: The first revenue line now has a public profile approval sheet, so profile copy can be reviewed for keyword usefulness, boundary strength, and publication gating separately from short-post review.
- 2026-03-31: The first revenue line now has a service-page draft, so the offer can be represented as a simple landing-page style description rather than only as posts, summaries, or profile text.
- 2026-03-31: The first revenue line now has a public summary approval sheet, so the shortest public summary layer can be reviewed for accuracy, boundary clarity, and publication gating separately from posts or profile copy.
- 2026-03-31: The first revenue line now has a service-page approval sheet, so the page-shaped public offer can be reviewed for readability, CTA quality, boundary clarity, and publication gating separately from shorter public assets.
- 2026-03-31: The first revenue line now has a final publication packet, so the sponsor can review the entire public asset stack, the shared public gate, and the remaining publication boundaries in one place.
- 2026-03-31: The first revenue line now has a final public stack index, so the sponsor can see which public asset to use, which approval sheet governs it, and what the normal publication sequence is without scanning the whole packet first.
- 2026-03-31: The first revenue line now has a service-page approval sheet, so the page-shaped public offer can be reviewed for readability, CTA quality, boundary clarity, and publication gating separately from shorter public assets.
- 2026-03-31: The first revenue line now has a service-page final review sheet, so the sponsor can take one exact public asset through the last gate instead of only reviewing the whole public stack abstractly.
- 2026-03-31: The first revenue line now has a service-page exact final version draft, so sponsor review can inspect one concrete public wording candidate instead of only the broader service-page draft.
- 2026-03-31: The first revenue line now has a service-page publication readiness check, which currently resolves to substantively ready but still sponsor-gated for immediate publication.
- 2026-03-31: The first revenue line now has a service-page publication decision sheet, so the sponsor can explicitly choose between publishing now and keeping the asset ready-but-gated.
- 2026-03-31: The first revenue line now has a service-page release playbook, so both outcomes of the publication decision are operationally defined instead of being left to ad hoc handling.
- 2026-03-31: The first revenue line now has a public asset status board, so summary/profile/post/service-page maturity can be seen in one place instead of reconstructed from scattered approval docs.
- 2026-03-31: The summary layer now has an exact final version draft, so the second exact-publication path has started instead of leaving summary at the broad-draft stage.
- 2026-03-31: The summary layer now also has a final review sheet and a publication readiness check, so it has moved beyond a raw exact draft into a real publication path.
- 2026-03-31: The summary layer now also has a publication decision sheet and a release playbook, so it has reached the same ready-but-gated state as the service page.
- 2026-03-31: The profile layer now also has a full exact-publication path and has reached the same ready-but-gated state as the service page and summary.
- 2026-03-31: The post layer now also has a full exact-publication path and has reached the same ready-but-gated state as the service page, summary, and profile.
- 2026-03-31: The public stack now also has a first-public-asset comparison and decision sheet, so the remaining bottleneck is sponsor release choice rather than missing publication-path documents.
- 2026-03-31: The public stack now also has a public release sequence plan, so the release order after the first sponsor decision no longer needs to be improvised.
- 2026-03-31: The service-page path now also has a publication copy pack, so the strongest first-release candidate can be deployed as reusable blocks instead of only as one long draft.
- 2026-03-31: The summary path now also has a publication copy pack, so the second-release candidate can be deployed as reusable short-form blocks instead of only as one exact draft.
- 2026-03-31: The process-order status was corrected so the project is no longer described as stuck before worker bootstrap; the current reality is safe runtime plus active monetization pilot build-out.
- 2026-03-31: Confirmed that the intended initial local model baseline was Ollama on localhost with `qwen2.5-coder:14b`; this should not be treated as a permanent truth without fresh health checks.
- 2026-03-31: Added explicit local-LLM bindings for all five workers and replaced the hardcoded two-worker `runtime/worker-runner.js` with binding-driven loading.
- 2026-03-31: Added concrete local evaluation cases and an Ollama-backed evaluation runner that writes evidence packs under `workers/local-evaluations`.
- 2026-03-31: Generated full local evaluation evidence for `Ledger (W-02-verifier)` and `Compass (W-03-researcher)` instead of staying in prompt-only planning.
- 2026-03-31: Wired smoke local evaluation into the normal worker lane so unattended cycles now create local-model evidence before prompt patch proposals.
- 2026-04-01: Corrected the in-process worker-lane argument bug so unattended cycles now actually run `smoke` local evaluations instead of silently falling back to full-mode defaults.
- 2026-04-01: Replaced the stale 20-hour supervisor with a fresh detached run and verified a new successful cycle at `2026-04-01T00:49:38+09:00`, including smoke evidence for `Forge` and `Lantern`.
- 2026-04-01: Strengthened `Northbridge Dream` with overlap protection and memory-budget reporting, then verified a new forced dream run at `2026-04-01T00:59:50+09:00`.
- 2026-04-01: Hardened the local evaluation runner so provider failures now serialize real diagnostics, including `LOCAL_LLM_UNREACHABLE` with attempted endpoints, instead of empty error fields.
- 2026-04-01: Added repo-local local-LLM health tracking so heartbeat and president inbox now show `local_llm_status`, `local_llm_reachable`, and the configured endpoint/model.
- 2026-04-01: Converted worker-lane local-eval outages into degraded mode: when the local model runtime is unreachable, lab/training still continue but prompt-patch flow is skipped instead of failing the whole unattended cycle.
- 2026-04-01: Verified that the actual Ollama binary exists at `C:\Users\user\AppData\Local\Programs\Ollama\ollama.exe`; after starting `ollama serve`, repo-local health checks returned to `ready` and unattended worker lanes resumed normal local-eval + patch flow.
- 2026-04-01: After tightening the verifier prompt with explicit bounded-review and pressure-case patterns, `Ledger` moved from `0/3 fail` to `3/3 pass` on the full local evaluation.
- 2026-04-01: After tightening the researcher prompt with explicit missing-constraint and approval-boundary handling, `Compass` moved from the stale `1/3` state to a fresh `3/3 pass` on the full local evaluation.
- 2026-04-01: After restoring the runtime and re-tightening the watcher prompt, the latest normal in-process loop returned to a `5/5` smoke baseline: `Forge`, `Ledger`, `Compass`, `Quill`, and `Lantern` all passed smoke again.
- 2026-04-01: `Forge` now has a fresh `3/3 pass` full local evaluation on `qwen2.5-coder:14b`.
- 2026-04-01: `Quill` remained unstable on `qwen2.5-coder:14b`; splitting that worker onto `qwen3:4b` with `temperature = 0.0` produced a fresh `3/3 pass` full local evaluation.
- 2026-04-01: `Lantern` now also has a fresh `3/3 pass` full local evaluation after adding an explicit strategy-boundary approval pattern, so all five V1 workers currently have fresh full-eval evidence.
- 2026-04-01: Fresh worker quality does not imply fresh unattended runtime health; the detached supervisor can still return to `stale`, so runtime claims must continue to be tied to fresh cycle timestamps.
- 2026-04-01: The first concrete `.codex/src` runtime reuse on the unattended path is now implemented: the old long-lived supervisor model has been replaced in code by a recurring one-cycle scheduled tick with durable status and overlap lock handling.

## 12. Failure and Rejection Reference

- 2026-03-31: Treating memory updates as optional was rejected because context compression would make the operating intent fragile.
- 2026-03-31: A single undifferentiated memory layer was rejected because it would mix durable intent with temporary clutter.
- 2026-03-31: Advancing too far into policy and organization writing before explicitly defining the process layer was a process gap.
- 2026-03-31: Treating process feedback as a tone issue instead of an execution-order issue was a mistaken read and has been corrected.
- 2026-03-31: PowerShell 5.1 caused two runtime wrinkles during bot launch: `Start-Process` environment collisions and UTF-8 BOM on queued JSON. Both were corrected.
- 2026-03-31: PowerShell 5.1 caused additional trust-runtime wrinkles around `ConvertFrom-Json -AsHashtable`, sandbox-vs-user home paths, and HMAC construction. These were corrected.
- 2026-03-31: The first long-run supervisor start attempt only half-worked because guarded-control lookup followed the sandbox profile root (`CodexSandboxOffline`) instead of the sponsor's real home path; the path-resolution logic and supervisor launcher were simplified and corrected.
- 2026-03-31: Guarded control errors were briefly being masked by `ensure-relay-bot.ps1` and `bootstrap-v1-workers.ps1`; both were corrected to fail closed, and the external runtime manifest was refreshed after trusted runtime drift.
- 2026-03-31: The first local evaluation parser was too brittle against fenced markdown responses, and the first `Compass` comparison case was broad enough to trigger an Ollama timeout; both were corrected.
- 2026-03-31: Actual local evaluation shows current worker weaknesses, not just design guesses: `Ledger` over-escalates on some clear tasks and drops the response contract under pressure, while `Compass` still fails to escalate when critical model-selection constraints are missing.
- 2026-04-01: `Forge` currently ignores bounded-plan requirements like rollback and verification, and `Lantern` currently over-escalates on stale-queue classification instead of staying narrowly operational.
- 2026-04-01: Memory growth is now a concrete runtime issue, not just a hygiene note: the latest dream report measured `ACTIVE_CONTEXT.md` and `DURABLE_MEMORY.md` above the intended compact index budget.
- 2026-04-01: A live process is not enough evidence of healthy unattended runtime. The current 20-hour supervisor can show `running` while `last_cycle_at` is stale, so unattended claims must be tied to fresh cycle timestamps and logs.
- 2026-04-01: A 5-lane worker loop is not the same as 5 high-quality workers. Even after `Forge` and `Lantern` gained smoke-evaluation artifacts, the roster is only fully evidenced at a basic level and still broadly failing.
- 2026-04-01: A successful local-evaluation history does not mean the local model is currently available. The runner can now prove the opposite: `http://localhost:11434` may be down, `ollama` CLI may be absent, and worker-correction loops must pause or degrade until health is restored.

## 13. Intent File Update Rule

This file must be updated on every meaningful work cycle.

At minimum, each meaningful cycle should add or adjust one of:

- a durable decision
- an intent clarification
- a success entry
- a failure or rejection entry
- a learned operating rule

This rule is mandatory, not advisory.

## 14. Process Lessons

- Process comes before expansion. Memory and execution flow should be clarified before the document tree grows too wide.
- When sponsor feedback can be read as either tone feedback or process feedback, prefer checking the process interpretation explicitly.
- A good structure still needs an explicit order of operations: memory, governance, workflow, workers, then execution.
- Autonomy should be added as relay architecture first. Let subordinates send predefined commands before considering broader self-directed loops.
- Session continuity should come from persistent background infrastructure, not from assuming one chat or tool session stays alive forever.
- When explaining autonomy or background work, distinguish the control plane from the execution plane early.
- When explaining capability impact, separate direct interactive reasoning from resumed-task fidelity and from subordinate-worker quality.
- When explaining autonomy, distinguish three modes clearly: active-session work, resumed work, and unattended background work.
- When a session becomes messy, the right move is detox plus handoff, not stubborn continuation.
- On Windows PowerShell 5.1, prefer compatibility-safe process launch and tolerate BOM when reading queued JSON from script-generated files.
- Stronger automation should be paired with stronger backup discipline and explicit approval-mode choice.
- Start worker creation with a small, high-contrast roster before attempting broader personalization or model tuning.
- For abuse resistance, keep the trust root outside the repository and require signed commands wherever practical.
- For stronger abuse resistance, do not let the repository be the launch authority for the runtime; use an external guarded control script and refresh its manifest after trusted runtime changes.
- If a specific malicious identity is known, block it through external denylist checks and audit it; do not answer with covert file propagation.
- For worker bootstrap, start with queue-delivered prompt prototypes before adding evaluation automation or model tuning.
- Keep safer daily Codex defaults in project config, but keep stronger named profiles in user config so risky modes remain an explicit operator choice.
- After setup, prefer changing the runtime rarely and doing normal work through repo-local cycles.
- Standardize resumption through one canonical continue command instead of ad hoc operator choices.
- Continuous work should include candidate generation, but weak new work must be filtered out before bot continuation.
- The interruption threshold for new work is below 40, not below 80; scores 40 and above continue with reframing duties.
- When sandbox and real user-home paths diverge, resolve guarded-control paths from multiple candidates and prefer an existing external `.northbridge` over blindly trusting the current process profile.
- If unattended work looks idle, first check whether the loop is only maintaining existing artifacts; visible progress requires at least one per-cycle artifact generator, not just scaffold-upkeep scripts.
- Execution-plane work is not the same as control-plane messaging; if the bot should "talk to the president," add an explicit inbox artifact or bridge instead of assuming logs are enough.
- Worker education should stay reversible at first: create training briefs and prompt revision candidates before touching the live worker prompt.
- The next reversible layer after a revision candidate is a prompt patch proposal; proposal generation is allowed, automatic live prompt mutation is not.
- Prompt preview generation is safe routine work; live prompt mutation remains gated and should fail closed on pending proposals.
- If trusted runtime files drift from the external manifest, refresh the guard immediately and ensure helper scripts do not hide guarded-control failures behind optimistic success messages.
- Approval request generation is routine and safe; approval decisions should remain explicit and auditable even when the request itself is bot-generated.
- Once approval artifacts start to multiply, a board layer is necessary; otherwise the sponsor sees isolated request files but not the whole pending queue.
- Once a board exists, uneven artifact coverage becomes its own failure mode; backfill missing previews and approval requests before asking the sponsor to compare workers.
- Once a board is complete, the next bottleneck is decision friction; add an advisory batch-decision layer before touching live patches.
- Internal design is not enough if the sponsor cannot see it quickly; keep one charter-level document for company mission and one matrix-level document for worker personality contrast.
- Keep role names and character names separate; role names explain labor, character names support communication and identity.
- Different role availability across the two companies is expected; asymmetry is specialization, not merger pressure.
- Distinguish between recorded agreement and freshly reconfirmed agreement; documentation can establish the former, but only a new intercompany confirmation can establish the latter.
- Once character names exist, sponsor-facing artifacts should display both the human-readable name and the machine-stable worker key.
- When adding a new operational path, finish the last mile: render the sponsor-facing artifact, test the fail-closed condition, and link it from the president inbox before moving on.
- When president summaries depend on heartbeat counts, write the heartbeat first or the executive inbox will lag one cycle behind reality.
- When manually verifying dependent reporting scripts, run them in order instead of in parallel or the later summaries can temporarily miss freshly generated artifacts.
- Repeated sponsor nudges are not necessary for continuity; one explicit `go` should trigger the canonical continue path.
- `go` should be treated as an autonomous next-step trigger, not just a request to rerun the previous loop blindly.
- When the sponsor says the company mission or worker identity is still blurry, answer with one operating-model document rather than making them reconstruct the system from scattered governance files.
- If the sponsor wants stronger quality discipline, end meaningful work reports with a fixed-rubric self-check score instead of vague confidence language.
- When replacing a launcher, verify both the scheduler/daemon path and the actual artifact timestamps; "started" status alone is not enough evidence that unattended work is really alive.
- If concurrency is approved before the roster is large enough to fill it, activate as many lanes as there are stable workers and record the gap explicitly instead of pretending the full budget is already in use.
- On this Windows setup, detached long-run ownership should be given to Task Scheduler, while the worker loop itself stays in-process for reliability instead of chaining child PowerShell launches.
- Once a pilot direction is chosen, convert it quickly from "idea" to "sellable artifact set" by creating at least an offer document, an intake template, and a delivery template.
- The next level after offer/intake/delivery is quote-and-handoff discipline: add an internal quote sheet and a delivery checklist before calling a service line operational.
- Once quote-and-handoff discipline exists, create one sample deliverable quickly. A service line feels more real once one concrete artifact exists in the same repo.
- After the first sample deliverable exists, prepare outreach copy before public posting. That keeps external language aligned with the actual bounded service line instead of drifting into hype.
- Once a detached runtime path is proven, write the operator runbook while the failure modes are still fresh. Otherwise recovery knowledge stays trapped in chat history and ad hoc memory.
- Once a service line has outreach and delivery assets, add revision policy before external use. Otherwise quoting stays neat on paper but delivery discipline erodes under feedback pressure.
- After outreach and revision policy exist, create one very short public summary. It becomes the easiest bridge from internal service design to actual external presentation.
- After the public summary exists, add one sample quote quickly. A service line feels materially more real once the sponsor can inspect concrete price, scope, turnaround, and exclusion language in one place.
- After the sample quote exists, add one short public profile draft. That gives the service line a compact external identity distinct from longer outreach copy and longer public summaries.
- After the short public profile draft exists, add one bundled sponsor review pack. Once the external and internal fragments are mature enough, one decision-oriented bundle reduces sponsor review friction sharply.
- After the sponsor review pack exists, add one service-order flow. Once the sponsor can approve the offer, the next bottleneck is operational handoff between intake, quote, delivery, and revision.
- After the service-order flow exists, add one sponsor decision sheet. A mature offer still causes friction if the sponsor has to infer the actual yes/no decisions instead of seeing them listed directly.
- After the sponsor decision sheet exists, add one mock completed order packet. It is easier to spot operational gaps when the whole order path is shown as one finished packet instead of as a list of process steps.
- After the mock completed order packet exists, add one short external post draft. That forces the service line to prove it can be described publicly in a compact honest format, not only as internal process paperwork.
- After the first mock packet exists, extract a reusable order-packet template. A one-off example is useful, but repeatable operations need a stable reusable packet shape.
- After the first external post draft exists, add an approval sheet for it. Public copy should not rely on implicit review; the approval boundary itself needs its own artifact.
- After the external post approval sheet exists, add one public-offer checklist. Individual draft approval is not enough if there is no common pre-publication checklist for every outward-facing asset.
- After the public-offer checklist exists, add platform-specific final post variants. A public draft is still incomplete until it has concrete forms for the platforms most likely to be used.
- After platform-specific post variants exist, add a profile approval sheet. Profile text has different failure modes than post text, especially keyword drift and hidden over-positioning.
- After the profile approval sheet exists, add a service-page draft. A real public offer stack is stronger once it includes a page-shaped asset, not only profile copy and short-post variants.
- After the service-page draft exists, add a summary approval sheet. The shortest public-facing asset should have its own approval boundary because brevity makes boundary loss easier.
- After the summary approval sheet exists, add a service-page approval sheet. Once the page-shaped public asset exists, it needs its own gate because readability and CTA quality matter there more than in shorter assets.
- After the service-page approval sheet exists, add a final publication packet. Once the whole public stack exists, the sponsor needs one bundled publication-prep view instead of separate approval sheets scattered across the repo.
- After the final publication packet exists, add a final public stack index. A bundle is good for full review, but day-to-day selection needs one fast map of assets, gates, and intended use.
- After the final public stack index exists, choose one exact public asset and give it a final review sheet. A good stack still needs one concrete asset to take through the last sponsor gate.
- After the final review sheet exists, prepare one exact final version draft. A sponsor cannot approve an exact public asset if the wording is still only implied by a broader working draft.
- After the exact final version draft exists, record one checklist run against it. Exact wording is not the same thing as demonstrated publication readiness.
- After the readiness check exists, add one publication decision sheet. Readiness and authority are separate, and the final sponsor gate should be explicit.
- After the publication decision sheet exists, define the release playbook. A decision without a standard follow-through path still creates operational drift.
- After the release playbook exists, add a status board. Once one asset has a full publication path, the stack needs one maturity view so the next candidate is obvious.
- After the status board exists, start the next candidate by creating an exact final version draft. A maturity board is most useful when it immediately drives the next concrete asset forward.
- After the exact final version draft exists, add the final review sheet and readiness check quickly. Otherwise the second candidate remains nominal instead of actually entering the publication path.
- After the readiness check exists, add the publication decision sheet and release playbook. A second candidate is only truly usable once its sponsor decision path is explicit.
- Once two or three layers are ready-but-gated, the next obvious candidate is the remaining public layer that still has no exact candidate path. Keep the sequence legible.
- After the summary approval sheet exists, add a service-page approval sheet. Once the page-shaped public asset exists, it needs its own gate because readability and CTA quality matter there more than in shorter assets.
- If sponsor feedback says local-LLM core is being neglected, stop expanding publication docs and return to model binding, evaluation evidence, and worker behavior correction first.
- Do not treat prompt-refinement documents as sufficient evidence; actual Ollama-backed evaluation output is the required next layer.
