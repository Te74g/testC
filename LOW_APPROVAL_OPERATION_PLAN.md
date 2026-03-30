# Low-Approval Operation Plan

## 1. Purpose

This document defines how to make day-to-day operation quieter by reducing how often the system needs sandbox-escalated or out-of-repo actions.

The goal is not to bypass approvals.

The goal is to shrink the set of actions that need them.

## 2. Core Strategy

Use a two-phase model:

1. setup phase
2. steady-state phase

### Setup Phase

During setup, it is acceptable to:

- install guarded control into `%USERPROFILE%\\.northbridge`
- initialize trust and identity policy
- refresh the guarded manifest after trusted runtime changes
- restart the relay bot after trusted runtime changes

These actions may still require approval prompts.

### Steady-State Phase

After setup, daily operation should prefer:

- repo-local queue writes
- repo-local inbox processing
- repo-local worker materialization
- repo-local document generation
- repo-local Git snapshots

The steady-state phase should avoid changing `%USERPROFILE%\\.northbridge` unless runtime trust material truly needs to change.

## 3. What Should Stay Rare

Keep these rare:

- rerunning `install-runtime-guard.ps1`
- changing external trust policy
- changing external identity policy
- restarting the guarded relay bot
- widening Codex approval modes

If these happen too often, the runtime is not stable enough yet.

## 4. What Should Become Routine

Make these routine:

- enqueue worker tasks
- materialize worker prototypes
- update memory
- write evaluation bundles
- review generated outputs
- commit Git snapshots

These are the actions that should make up most work cycles.

## 5. Design Rule

If a recurring task needs out-of-repo writes, redesign the task until it usually runs inside the repository.

Examples:

- prefer generated artifacts under `workers/` over user-profile state
- prefer repo-local logs for non-sensitive operational artifacts
- prefer repo-local evaluation bundles over ad hoc external notes

## 6. Approval-Minimizing Runtime Principle

The relay bot and worker factory should be treated like a mostly fixed appliance after setup.

That means:

- adjust the runtime in batches
- re-pin once after a trusted change set
- then avoid touching the guarded layer during routine work

## 7. Next Practical Goal

The next practical goal is to shift effort from runtime modification into:

- worker evaluation
- worker promotion decisions
- money-making task experiments
- queue-driven execution loops
