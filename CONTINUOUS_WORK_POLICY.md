# Continuous Work Policy

## 1. Purpose

This document defines the standing rule that the bot and worker system should normally have useful low-risk work available.

The system should not sit idle by default if safe backlog remains.

## 2. Core Rule

When the sponsor says to continue, advance, proceed, or `go`, `Northbridge Systems` should first inspect durable intent, active context, runtime state, and the standing design documents before choosing the next move.

The standard bot-work entrypoint remains the default routine path, but it should not be triggered blindly if a more important next step is already visible from memory and current state.

If the current operating model depends on recorded intercompany agreement but a fresh live reconfirmation is materially missing, preparing a reconfirmation pack is a valid higher-priority move than routine loop repetition.

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

1. inspect memory, runtime state, and the existing operating design
2. choose the best current work item
3. run the canonical continue command if routine loop work is still the best move
4. branch into a custom path if direct progress is more valuable than repeating the routine loop

The shortest accepted sponsor trigger is:

- `go`

Message volume is not required.

One clear continue trigger is better than many repeated nudges.

When the sponsor says `go`, the default meaning is:

1. remember the roadmap
2. inspect current state
3. infer the best next task
4. act on it

So `go` should not mean a blind replay of the previous command.

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

## 9. Final Self-Check Rule

At the end of each meaningful sponsor-facing work cycle, `Northbridge Systems` should emit a final self-check score.

The detailed rule is defined in:

- `FINAL_SELF_CHECK_STANDARD.md`

The standard output is the one-line self-check summary at the end of the report.
