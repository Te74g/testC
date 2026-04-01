# Long Run Policy

## 1. Purpose

This document defines how to run the system for long windows such as 20 hours without relying on one fragile foreground session.

## 2. Core Model

Long runs should use a background supervisor.

The supervisor should:

- keep the relay bot available
- trigger the canonical continue command
- write heartbeat records
- stop after the requested time window

## 3. Default Entry Point

The standard start command is:

- `scripts/start-long-run-supervisor.ps1`

On Windows, the preferred detached ownership model is:

- Task Scheduler recurring tick execution

Inside each scheduled tick, the loop executes:

- `scripts/continue-bot-work.ps1`
- `scripts/write-bot-work-heartbeat.ps1`

For background reliability, the unattended path now uses:

- `scripts/run-supervisor-tick.ps1`
- in-process worker batches
- a tick lock to prevent overlap

This replaced the older long-lived detached supervisor model.

## 4. Current Scope

The current long-run scope is low-risk and repository-focused.

It is suitable for:

- worker prototype upkeep
- evaluation bundle upkeep
- promotion review scaffolding
- relay health checks
- heartbeat logging

It is not yet a full autonomous monetization loop.

## 5. Current Approved Runtime Budget

The sponsor has approved:

- long unattended windows up to 20 hours as the normal target
- a current supervisor cadence of 5-minute intervals
- up to 10 concurrent worker slots

Current reality:

- the orchestration runtime now supports 5 effective worker-education lanes across the current V1 roster
- the 10-slot budget is approved and recorded, but only 5 lanes are active because only 5 workers currently exist
- because current system load is acceptable, higher cadence is now allowed even before the parallel-lane refactor is finished
- the detached Windows supervisor has been reworked to survive outside the current Codex session by launching through Task Scheduler recurring ticks
- the recurring tick path has now been observed to finish cleanly and return status to `scheduled` across at least two cycles

## 6. Status and Stop

Use:

- `scripts/status-long-run-supervisor.ps1`
- `scripts/stop-long-run-supervisor.ps1`

The current operator runbook is:

- `WINDOWS_LONG_RUN_OPERATOR_RUNBOOK_V1.md`

## 7. Boundary

Long runs do not bypass:

- sponsor approval
- external escalation boundaries
- new-work quality gate rules

## 8. Infinite Work Clarification

The system should try to avoid idle time.

But long-run work should still remain:

- low-risk
- reversible
- explainable
- auditable
