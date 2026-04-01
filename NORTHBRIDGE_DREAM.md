# Northbridge Dream

## Purpose

`Northbridge Dream` is the local memory-consolidation counterpart to the exposed `.codex/src/services/autoDream` design.

It exists to:

- watch for enough new unattended work to justify consolidation
- summarize recent worker evidence and president-inbox signal
- recommend corrections without silently rewriting durable memory
- keep the system anchored to local-LLM reality instead of easier documentation expansion

## Trigger Model

`Northbridge Dream` is intentionally not an every-cycle task.

It uses:

- a time gate
- a new-signal gate
- a lock gate
- a repo-local scheduler

Current config lives in:

- `runtime/config/northbridge-dream.v1.json`
- `runtime/config/scheduled-jobs.v1.json`

## Inputs

The dream report currently reads:

- `runtime/state/work-heartbeat/latest.json`
- `runtime/state/long-run-supervisor.status.json`
- recent files under `runtime/inbox/president`
- recent files under `workers/local-evaluations`
- `memory/ACTIVE_CONTEXT.md`
- `memory/DURABLE_MEMORY.md`

## Outputs

The dream writes:

- timestamped reports under `runtime/dream/reports`
- the latest rendered report at `runtime/dream/latest.md`
- execution state at `runtime/state/northbridge-dream.state.json`
- a transient lock at `runtime/state/northbridge-dream.lock`

## Discipline

`Northbridge Dream` now also checks:

- stale-holder protection so overlapping dream runs do not stack
- memory size against a compact index budget

The current memory budget follows the exposed `memdir` pattern:

- `200` lines
- `25 KB`

## Rule

`Northbridge Dream` is advisory.

It may recommend:

- prompt corrections
- worker-priority changes
- memory cleanups
- refocus toward local-evaluation work

It must not silently rewrite durable intent or bypass sponsor authority.
