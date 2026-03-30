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

## 12. Failure and Rejection Reference

- 2026-03-31: Treating memory updates as optional was rejected because context compression would make the operating intent fragile.
- 2026-03-31: A single undifferentiated memory layer was rejected because it would mix durable intent with temporary clutter.
- 2026-03-31: Advancing too far into policy and organization writing before explicitly defining the process layer was a process gap.
- 2026-03-31: Treating process feedback as a tone issue instead of an execution-order issue was a mistaken read and has been corrected.
- 2026-03-31: PowerShell 5.1 caused two runtime wrinkles during bot launch: `Start-Process` environment collisions and UTF-8 BOM on queued JSON. Both were corrected.

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
