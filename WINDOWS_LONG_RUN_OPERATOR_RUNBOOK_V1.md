# Windows Long-Run Operator Runbook V1

## 1. Purpose

This runbook explains how to operate the detached long-run supervisor on this Windows machine.

It is written for the current project state:

- detached ownership via Task Scheduler
- PowerShell supervisor loop
- in-process worker batch execution
- relay bot kept separate from the long-run supervisor

## 2. What “Healthy” Looks Like

A healthy long run should show all of the following:

- `scripts/status-long-run-supervisor.ps1` returns `status=running`
- `runtime/state/long-run-supervisor.status.json` shows `last_result = ok`
- `runtime/state/work-heartbeat/latest.json` keeps getting newer timestamps
- new files continue appearing under `runtime/inbox/president/`
- `runtime/logs/long-run-supervisor.jsonl` continues adding `supervisor_cycle_ok`

## 3. Standard Commands

### Start the default 20-hour run

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-long-run-supervisor.ps1
```

### Start a shorter test run

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-long-run-supervisor.ps1 -Hours 0.05 -IntervalMinutes 1
```

### Check status

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\status-long-run-supervisor.ps1
```

### Stop the supervisor

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\stop-long-run-supervisor.ps1
```

### Check relay bot status

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\status-relay-bot.ps1
```

## 4. Key Files To Watch

- supervisor status:
  - `runtime/state/long-run-supervisor.status.json`
- supervisor PID:
  - `runtime/state/long-run-supervisor.pid`
- heartbeat:
  - `runtime/state/work-heartbeat/latest.json`
- supervisor log:
  - `runtime/logs/long-run-supervisor.jsonl`
- president inbox:
  - `runtime/inbox/president/`

## 5. Current Ownership Model

On this Windows setup:

- detached launch is owned by Task Scheduler
- active task name: `NorthbridgeLongRunSupervisor`
- the actual work loop is run by `scripts/long-run-supervisor.ps1`
- each cycle calls `scripts/continue-bot-work.ps1 -InProcess`

This means the right place to debug a detached run is not only the current terminal. The operator should always check the status JSON and log files.

## 6. Normal Start Procedure

1. Confirm the relay bot exists and is healthy.
2. Start the supervisor with `start-long-run-supervisor.ps1`.
3. Wait a few seconds.
4. Run `status-long-run-supervisor.ps1`.
5. Confirm:
   - `status=running`
   - a PID is present
   - the status JSON exists
6. After the first interval, confirm:
   - `cycle_count` increased
   - `last_result = ok`
   - heartbeat timestamp advanced

## 7. Normal Stop Procedure

1. Run `stop-long-run-supervisor.ps1`.
2. Confirm the status file now says:
   - `state = stopped`
   - `last_result = stopped_by_operator`
3. Confirm the PID is no longer active.

Do not manually kill random PowerShell processes unless the scripted stop path fails.

## 8. Stale-State Recovery

Use this if status looks wrong, the PID is stale, or the supervisor did not really start.

### Case A: Status says running but process is gone

Action:

- run `status-long-run-supervisor.ps1`

Expected behavior:

- it should rewrite stale running status into `stopped` with `last_result = stale_status`

### Case B: Start command returns but no status file appears

Action:

- rerun the start command
- if it still fails, check:
  - Task Scheduler access
  - `runtime/logs/long-run-supervisor.jsonl`
  - whether the supervisor script changed recently

### Case C: Supervisor runs but cycle count does not move

Action:

1. inspect `runtime/logs/long-run-supervisor.jsonl`
2. inspect `runtime/state/work-heartbeat/latest.json`
3. run a direct foreground check:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\continue-bot-work.ps1 -InProcess
```

If the foreground path fails, fix that first. The detached loop depends on it.

## 9. Health Checks

### Fast health check

- status is `running`
- `last_result = ok`
- heartbeat timestamp is recent

### Stronger health check

- `cycle_count` increases across checks
- heartbeat counters increase
- a new president inbox message appears

## 10. Safe Recovery Rule

If a detached run becomes ambiguous:

- do not guess
- stop the supervisor cleanly
- confirm stale state is cleared
- verify `continue-bot-work.ps1 -InProcess` in foreground
- start the detached run again

This is safer than trying ad hoc process surgery.

## 11. Escalation Boundary

This runbook does not override sponsor approval.

Starting or monitoring the long-run supervisor is allowed operational work.

Anything involving:

- external publication
- external spending
- external credentials
- destructive irreversible actions

still stays under sponsor approval.

## 12. Next Improvement

The next operational improvement after this runbook should be one of:

- a short recovery checklist for the relay bot itself
- a one-page public service summary
- an internal revision policy for paid deliverables
