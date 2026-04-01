# Sample Technical Brief

## 1. Executive Summary

- question: On a Windows development machine, should an unattended local AI workflow rely on a user-space launcher or Task Scheduler for detached long-run operation?
- short answer: Use Task Scheduler as the detached ownership layer, and keep the actual worker loop inside a controlled in-process PowerShell supervisor.
- recommended action: Standardize the Windows long-run path on `Task Scheduler -> PowerShell supervisor -> in-process worker batch`, and treat direct child-process launchers as fallback-only.

## 2. Problem Framing

The real decision is not "how do we start a script."

The real decision is which Windows-owned execution path can keep a long unattended run alive after the current interactive session returns, while still leaving clear logs, status, and approval boundaries.

This matters because a local AI workshop that depends on one fragile foreground shell is not operationally credible. If the detached path dies silently, the company looks active on paper but stops producing work.

## 3. Context

- current environment: Windows machine, PowerShell-based orchestration, local relay runtime, detached background supervisor, sponsor approval model
- important assumptions:
  - the machine is not a full server environment
  - the workflow must survive outside the current Codex shell
  - the system needs auditable status, logs, and heartbeat artifacts
- relevant constraints:
  - approval boundaries still apply
  - child PowerShell spawning inside detached background flows has been fragile
  - the current worker roster is five workers, with ten approved slots but only five active lanes

## 4. Options Considered

### Option 1: User-space launcher only

- description: Start a detached process directly from the current shell using normal child-process launch logic.
- strengths:
  - simple to implement
  - minimal Windows integration
  - good for foreground experiments
- weaknesses:
  - fragile ownership when the parent context returns
  - inconsistent persistence in this environment
  - harder to trust for multi-hour runs

### Option 2: Task Scheduler plus in-process supervisor

- description: Give detached ownership to Windows Task Scheduler, then run the actual long-run loop inside one PowerShell supervisor process that handles the worker batch in-process.
- strengths:
  - detached ownership is handled by Windows instead of the current shell
  - status and PID remain legible
  - avoids the unstable `detached process -> child PowerShell -> more child PowerShell` chain
  - proved workable in the current project
- weaknesses:
  - requires permission to register and start scheduled tasks
  - Windows-specific behavior must be documented
  - still not the same as a hardened service host

### Option 3: Detached Node daemon that spawns PowerShell children

- description: Use a Node-based daemon as the long-run supervisor, with PowerShell scripts spawned beneath it.
- strengths:
  - feels flexible
  - easy to structure logs and status as JSON
  - could fit future cross-platform ideas
- weaknesses:
  - in the current environment, child PowerShell spawn reliability broke the loop
  - detached process looked started while actual work failed
  - added an extra failure layer without improving real execution durability

## 5. Recommendation

Choose **Option 2: Task Scheduler plus in-process supervisor**.

Why it wins:

- it solves the actual ownership problem instead of only changing syntax
- it preserves a clean detached process model on Windows
- it reduces failure surface by keeping the worker batch inside one PowerShell supervisor instead of nesting multiple external spawns
- it has already been validated in this project through detached multi-cycle execution

Accepted tradeoff:

- this is a Windows-operational answer, not a universal orchestration answer

What to do next:

1. Keep the Windows detached path standardized on Task Scheduler.
2. Keep the worker batch in-process for the long-run supervisor.
3. Revisit true multi-process worker parallelism only after the current 5-lane batch path is stable over longer windows.

## 6. Risks And Unknowns

- unresolved risk 1: Task Scheduler access may require elevation or explicit permission in some environments.
- unresolved risk 2: In-process batch execution is reliable now, but it is less parallel than a future fully separated worker-host model.
- open question 1: When the roster grows beyond five workers, should Windows keep one supervisor with batched work, or should some workers move into separate long-lived service lanes?

## 7. Implementation Notes

- detached launcher:
  - `scripts/start-long-run-supervisor.ps1`
- supervisor loop:
  - `scripts/long-run-supervisor.ps1`
- canonical work loop:
  - `scripts/continue-bot-work.ps1 -InProcess`
- batch worker path:
  - `scripts/run-parallel-worker-lanes.ps1 -InProcess`

Validation signals to watch:

- `scripts/status-long-run-supervisor.ps1`
- `runtime/state/work-heartbeat/latest.json`
- `runtime/logs/long-run-supervisor.jsonl`
- latest file under `runtime/inbox/president/`

## 8. Confidence And Limits

- high confidence:
  - Task Scheduler plus in-process supervisor is the best fit for this current Windows project
  - the detached path now works in practice, not just in theory
- still needs validation:
  - longer uninterrupted runtime beyond the first verified cycles
  - operational behavior after larger worker roster growth
- outside the scope of this brief:
  - Linux service management
  - cloud orchestration
  - monetization or pricing decisions

## 9. Handoff

- immediate next action: keep monitoring the live 20-hour run and avoid changing the detached path unless status or heartbeat drifts
- owner: `Northbridge Systems`
- suggested follow-up deliverable: a short operator runbook for `start / status / stop / recovery` on Windows
