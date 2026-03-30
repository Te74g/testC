# Intent File

This file is the mandatory intent file and durable reference for `Northbridge Systems`.

## 1. Why This Exists

This project exists to build a sponsor-governed AI operating structure where:

- `Northbridge Systems` and the `Claude-side company` function like separate allied companies
- both companies can manage workers, coordinate, review each other, and create value
- local LLM workers are used to reduce dependence on expensive external models
- the sponsor remains final authority over money, risk, and irreversible action

## 2. Parties

- Sponsor: human owner, capital provider, final approver
- `Northbridge Systems`: Codex-side company focused on systems, foundation, governance, implementation discipline, and worker creation standards
- `Claude-side company`: Claude Code-side company focused on research, strategy, critique, synthesis, and meeting preparation

The permanent company name for the Claude-side company is still pending and must be chosen by Claude Code.

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
- the `Claude-side company`
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
- Claude-side company name is pending Claude Code's own choice
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
- for multi-hour unattended windows, the standard launcher should be `scripts/start-long-run-supervisor.ps1`
- net-new work must go through web-based multi-angle analysis and a 0-100 self-check score before entering the bot loop
- only scores below 40 should truly interrupt new work; scores 40 and above stay in managed circulation with mandatory reframing based on score band

## 11. Success Reference

- 2026-03-31: Established the two-company operating model with sponsor authority kept explicit.
- 2026-03-31: Chose `Northbridge Systems` as the Codex-side company name and left the Claude-side company name for Claude Code to choose.
- 2026-03-31: Created the foundation documents for roles, worker creation, intercompany coordination, sponsor approval, and GPT research brokering.
- 2026-03-31: Added a two-layer memory system to reduce context-loss risk.
- 2026-03-31: Allowed shared documents to contain direct instructions for Claude Code while requiring post-completion cleanup.
- 2026-03-31: Corrected the evaluation frame from "lack of affirmation" to "lack of process" and treated the distinction as an operating-level correction.
- 2026-03-31: Added an explicit process-order document so future expansion follows memory, governance, communication, workers, execution, monetization, then expansion.
- 2026-03-31: Created the first presidents' meeting pack and the first small worker roster so the project can move from policy into initial operation design.
- 2026-03-31: Clarified that future autonomy should include subordinate-mediated command relay so the system can resume or re-instruct itself in controlled ways.
- 2026-03-31: Added a command-relay specification so future self-resume and self-instruction can be built as structured relay commands instead of free-form control text.
- 2026-03-31: Added a background-operation specification so continuity can move to a queue-driven local bot and avoid interrupting the sponsor's normal PC work.
- 2026-03-31: Added a worker-leasing protocol so `Northbridge Systems` workers can be temporarily borrowed by the Claude-side company under bounded rules.
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

## 12. Failure and Rejection Reference

- 2026-03-31: Treating memory updates as optional was rejected because context compression would make the operating intent fragile.
- 2026-03-31: A single undifferentiated memory layer was rejected because it would mix durable intent with temporary clutter.
- 2026-03-31: Advancing too far into policy and organization writing before explicitly defining the process layer was a process gap.
- 2026-03-31: Treating process feedback as a tone issue instead of an execution-order issue was a mistaken read and has been corrected.
- 2026-03-31: PowerShell 5.1 caused two runtime wrinkles during bot launch: `Start-Process` environment collisions and UTF-8 BOM on queued JSON. Both were corrected.
- 2026-03-31: PowerShell 5.1 caused additional trust-runtime wrinkles around `ConvertFrom-Json -AsHashtable`, sandbox-vs-user home paths, and HMAC construction. These were corrected.
- 2026-03-31: The first long-run supervisor start attempt only half-worked because guarded-control lookup followed the sandbox profile root (`CodexSandboxOffline`) instead of the sponsor's real home path; the path-resolution logic and supervisor launcher were simplified and corrected.

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
