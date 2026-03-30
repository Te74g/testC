# Continuous Work Policy

## 1. Purpose

This document defines the standing rule that the bot and worker system should normally have useful low-risk work available.

The system should not sit idle by default if safe backlog remains.

## 2. Core Rule

When the sponsor says to continue, advance, or proceed, `Northbridge Systems` should prefer triggering the standard bot-work entrypoint rather than improvising a new path each time.

The canonical entrypoint is:

- `scripts/continue-bot-work.ps1`

For longer unattended windows, the canonical launcher is:

- `scripts/start-long-run-supervisor.ps1`

## 3. Why This Exists

This rule creates:

- a predictable operating rhythm
- fewer ad hoc commands
- lower supervision burden
- fewer repeated decisions about how to resume work

## 4. Standing Low-Risk Work

If no higher-priority approved task is waiting, the system should prefer:

- worker bootstrap for missing prompt prototypes
- worker evaluation bundle scaffolding
- memory refresh and cleanup
- queue review
- document cleanup
- Git snapshot reminders

If routine backlog becomes thin, candidate new work may be generated.

But candidate new work must first pass the quality gate in:

- `NEW_WORK_QUALITY_GATE.md`

Candidate work scoring `40+` should stay in managed circulation even if it must be reframed before execution.

## 5. Idle Rule

Idle should be explicit, not accidental.

If the bot is idle, one of these should be true:

- no approved low-risk work remains
- approval is required
- the sponsor explicitly paused work
- the sleeping component has reached a limit

## 6. Sponsor Interaction Rule

When the sponsor wants progress, `Northbridge Systems` should prefer:

1. run the canonical continue command
2. observe what work was created or completed
3. only branch into a custom path if the standard path is insufficient

## 7. Boundaries

This rule does not authorize:

- spending
- irreversible actions
- external publication
- production deployment
- bypass of approval requirements

The policy is about continuity, not expanded authority.

## 8. Infinite Work Clarification

The system should aim for continuous useful work rather than accidental idle time.

That means:

- keep routine low-risk backlog available
- generate candidate new work when backlog is thin
- filter net-new work through the quality gate before bot continuation
