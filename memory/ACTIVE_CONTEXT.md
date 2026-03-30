# Working Memory

This file is the mandatory working memory for current execution state.

## 1. Current Objective

Move from documented policy into the first operational setup for creating and refining distinctive local LLM workers.

The immediate focus is to define the first safe execution loop that can keep working even when the sponsor is not continuously present.

## 2. What Has Been Established

- `Northbridge Systems` has been chosen as the Codex-side company name
- the Claude-side company name is intentionally left for Claude Code to choose
- a shared foundation has been written
- worker creation rules have been written
- intercompany coordination rules have been written
- sponsor approval rules have been written
- GPT/sponsor research brokering has been written
- direct instructions to Claude in shared documents are allowed if they stay scoped and are cleaned up after completion
- a two-layer memory system has now been introduced
- memory updates have been elevated from recommended practice to mandatory operating discipline
- the recent self-check clarified that the main deficit so far was process order, not lack of affirmation
- an explicit process-order document has now been added
- the first presidents' meeting pack has been created
- the first worker roster has been created
- a long-term premise has been clarified: subordinate workers or bots should eventually be able to relay predefined commands that resume or redirect work
- a command-relay specification has now been created
- background continuity and low interruption have now been added as explicit design goals
- intercompany worker leasing has now been added as an intended operating feature
- worker leasing has been tightened so leasable and non-leasable workers are now explicitly separated
- the background model has been clarified as control plane plus execution plane
- the capability question has been clarified: the main risk is context-fidelity loss during resume, not automatic loss of core reasoning ability
- the early mission has been clarified as building and operating the system to create distinctive local LLM workers with less sponsor babysitting
- the unattended-operation question has been clarified: without a bot/runtime layer, the system cannot truly continue alone after the interactive session ends
- session detox and sleep-on-usage-cap rules have now been added
- the first local relay runtime has now been implemented and a queued `nc.memory` command has been processed successfully end-to-end
- Codex approval-mode guidance from the sponsor has now been incorporated into project policy
- Git backup discipline has now been incorporated into project policy
- the repository has now been pushed to GitHub on `origin/main`
- the first local worker-factory plan has now been documented
- the relay runtime has now been hardened with an external trust policy and signed queued commands
- the hardened runtime has been verified with one accepted signed command and one rejected untrusted sender
- guarded external relay control has now been installed and verified so runtime start and enqueue can be pinned to trusted file hashes outside the repository
- a blocked-identity denylist has now been initialized so known malicious Git identities can be refused before guarded runtime control continues
- the relay bot can now accept `nc.worker.seed`, and the first five prompt-only worker prototypes have been materialized into `workers/prototypes`
- this repository now has a project-scoped `.codex/config.toml` for safer everyday Codex approval-mode defaults
- a low-approval steady-state plan is now being added so day-to-day worker loops stay mostly repo-local after setup
- a continuous-work rule is now being added so the standard response to "continue" is a canonical bot-work command
- the canonical continue command has now been verified end to end and can be used as the normal path when the sponsor says to keep moving
- a long-run supervisor is now being added so the current low-risk work loop can stay active for multi-hour windows
- a mandatory new-work quality gate is now being added so net-new work is researched and scored before entering the bot loop
- the new-work quality gate now has a reusable scorecard template for actual use
- the quality-gate banding has been corrected so only scores below 40 interrupt; scores 40 and above continue with required reframing
- the current guarded-runtime and worker-factory batch has now been pushed to `origin/main`
- worker promotion reviews and work-heartbeat logging now exist
- the long-run supervisor has now been corrected, started, and verified through its first successful cycle

## 3. Current Document Set

Core policy documents currently include:

- `COMPANY_FOUNDATION.md`
- `WORKER_CREATION_MANUAL.md`
- `ORGANIZATION_REGISTRY.md`
- `INTERCOMPANY_PROTOCOL.md`
- `SPONSOR_APPROVAL_MANUAL.md`
- `GPT_RESEARCH_BROKER.md`
- `PROCESS_ORDER.md`
- `COMMAND_REGISTRY_V1.md`
- `QUEUE_SCHEMA_V1.md`
- `SESSION_CONTINUITY_PROTOCOL.md`
- `BACKGROUND_OPERATION_SPEC.md`
- `COMMAND_RELAY_SPEC.md`
- `CODEX_APPROVAL_MODES_POLICY.md`
- `GIT_BACKUP_POLICY.md`
- `LOCAL_WORKER_FACTORY.md`
- `SECURITY_HARDENING.md`
- `TRUST_POLICY_V1.md`
- `runtime/identity-policy.example.v1.json`
- `scripts/install-runtime-guard.ps1`
- `scripts/bootstrap-v1-workers.ps1`
- `scripts/materialize-worker-prototypes.ps1`
- `workers/worker-catalog.v1.json`
- `workers/README.md`
- `.codex/config.toml`
- `.codex/config.user-profiles.example.toml`
- `.codex/README.md`
- `LOW_APPROVAL_OPERATION_PLAN.md`
- `scripts/daily-worker-cycle.ps1`
- `CONTINUOUS_WORK_POLICY.md`
- `scripts/ensure-relay-bot.ps1`
- `scripts/scaffold-worker-evaluations.ps1`
- `scripts/continue-bot-work.ps1`
- `NEW_WORK_QUALITY_GATE.md`
- `memory/MEMORY_SYSTEM.md`
- `memory/DURABLE_MEMORY.md`
- `memory/ACTIVE_CONTEXT.md`

## 4. Likely Next Steps

- define the first safe execution loop on top of the running relay runtime
- add `nc.call` and `nc.resume` end-to-end tests
- define the first evaluation bundle for the generated worker prototypes
- decide whether to also patch the user-level `~/.codex/config.toml` with named profiles
- use the new low-approval steady-state plan to avoid unnecessary guarded-layer changes
- make the canonical continue command the normal path when the sponsor asks the system to keep moving
- monitor the active 10-hour supervisor run and snapshot meaningful repo changes while it is active
- apply the new-work quality gate before any new monetization or runtime expansion work
- prepare shared instruction templates specifically addressed to Claude Code
- identify the first candidate money-making task categories
- later design a bounded command-relay layer for self-resume and self-instruction
- later create the command registry file and first safe relay commands
- later define the local queue format and minimal background relay bot
- the minimal bot/runtime layer is now a prerequisite for meaningful unattended operation
- later test the first safe leased-worker use case between the two companies
- later ensure the bot runtime avoids blind retry loops when a target is sleeping or capped
- later design stronger task bundles so resumed work keeps high-fidelity context
- later replace `Claude-side company` with its chosen permanent name

## 5. Open Questions

- what permanent name Claude Code will choose for its own company
- what the first real money-making task categories should be
- which first worker roles should exist before live execution begins

## 6. Active Constraints

- sponsor approval remains mandatory for money, external actions, and irreversible actions
- active context should stay compact and be cleaned aggressively
- durable memory should hold stable decisions only
- the intent file must be updated on every meaningful work cycle
- working memory should be updated on every work cycle by default
- future expansion should follow a clearer process order than the initial pass did
- the current active phase is worker bootstrap
- the next transition is from worker bootstrap into execution sandbox design
- future self-instruction must be structured as bounded relay commands, not as unrestricted executive authority
- background continuity should be achieved through persistent infrastructure, not by relying on the current interactive session to remain active
- unclear worker lease status should default to non-leasable until explicitly changed
- the first autonomous-looking loop still has to stay within sponsor approval boundaries for cost, external action, and irreversible change
- the current relay runtime is intentionally narrow and should stay low-risk until more commands are verified
- guarded control should become the preferred runtime entrypoint after installation
- covert file spraying into personal folders is explicitly out of bounds; blocked identities should be handled by denial and audit
- the current worker creation loop is still prompt-only; model selection, testing, and promotion have not been automated yet
- the current long-run supervisor window started at 2026-03-31 03:06 JST and is scheduled to stop around 2026-03-31 13:06 JST if left undisturbed
- the live supervisor PID is 85040 and the live relay bot PID is 45768

## 7. Cleanup Notes

Delete or condense items in this file when:

- the step is complete
- the question is resolved
- the plan has changed
- the note no longer helps the next execution step

If a line becomes permanently important, move the durable part into `DURABLE_MEMORY.md`.

## 8. Working Memory Update Rule

This file should be updated on basically every work cycle.

If it is not updated, that should be rare and should only happen when there is truly no meaningful change in state.

Default expectation:

- refresh what changed
- refresh what is next
- remove stale lines
