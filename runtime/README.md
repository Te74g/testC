# Runtime

This directory contains the local background relay runtime.

## Main Files

- `command-registry.v1.json`
- `relay-bot.js`

## Key Subdirectories

- `queue/`
- `inbox/`
- `logs/`
- `state/`
- `config/`

These directories are created automatically by the runtime scripts.

## PowerShell Scripts

Use these scripts from the project root:

- `scripts/start-relay-bot.ps1`
- `scripts/status-relay-bot.ps1`
- `scripts/enqueue-command.ps1`
- `scripts/stop-relay-bot.ps1`
- `scripts/init-trust-policy.ps1`
- `scripts/install-runtime-guard.ps1`
- `scripts/bootstrap-v1-workers.ps1`
- `scripts/materialize-worker-prototypes.ps1`
- `scripts/daily-worker-cycle.ps1`
- `scripts/ensure-relay-bot.ps1`
- `scripts/scaffold-worker-evaluations.ps1`
- `scripts/scaffold-worker-promotion-reviews.ps1`
- `scripts/advance-worker-lab.ps1`
- `scripts/draft-worker-training-pack.ps1`
- `scripts/draft-worker-patch-proposal.ps1`
- `scripts/render-worker-prompt-preview.ps1`
- `scripts/draft-worker-patch-approval-request.ps1`
- `scripts/set-worker-patch-proposal-decision.ps1`
- `scripts/apply-approved-worker-patch.ps1`
- `scripts/continue-bot-work.ps1`
- `scripts/write-bot-work-heartbeat.ps1`
- `scripts/write-president-message.ps1`
- `scripts/start-long-run-supervisor.ps1`
- `scripts/status-long-run-supervisor.ps1`
- `scripts/stop-long-run-supervisor.ps1`
- `scripts/check-local-llm-runtime.ps1`

## Trust Policy

For real use, initialize the external trust policy first:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\init-trust-policy.ps1
```

This creates:

- `%USERPROFILE%\.northbridge\trust-policy.v1.json`
- `%USERPROFILE%\.northbridge\identity-policy.v1.json`

The relay bot uses the external trust policy as its trust root.

For hardened use, install the guarded external control layer:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-runtime-guard.ps1
```

This creates:

- `%USERPROFILE%\.northbridge\runtime-manifest.v1.json`
- `%USERPROFILE%\.northbridge\northbridge-relay-control.ps1`

After that, prefer the external control script over the in-repo control scripts.

The identity policy can block known disallowed Git users before runtime control proceeds.

## Example Commands

Start:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-relay-bot.ps1
```

Status:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\status-relay-bot.ps1
```

Queue a memory command:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\enqueue-command.ps1 `
  -Command nc.memory `
  -Sender "Northbridge Systems" `
  -Receiver "Northbridge Systems" `
  -Reason "refresh active memory" `
  -MemoryTarget active `
  -MemoryOperation refresh
```

Guarded control example:

```powershell
powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\.northbridge\northbridge-relay-control.ps1 `
  -Action Enqueue `
  -Command nc.memory `
  -Sender "Northbridge Systems" `
  -Receiver "Northbridge Systems" `
  -Reason "refresh active memory" `
  -MemoryTarget active `
  -MemoryOperation refresh
```

Bootstrap the first five worker seeds:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-v1-workers.ps1
```

Materialize worker prototypes from the worker inbox:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\materialize-worker-prototypes.ps1
```

Run the normal repo-local worker cycle:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\daily-worker-cycle.ps1
```

Run the canonical continue command:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\continue-bot-work.ps1
```

This continue loop now creates one new worker-lab iteration plan on each pass so unattended cycles produce visible new artifacts instead of maintenance-only no-ops.

It also writes a short president-facing inbox message under `runtime/inbox/president/` so the control plane has something explicit to read on the next executive check.

It now drafts a worker training pack as well, so each cycle can produce a training brief and a prompt revision candidate for the current worker target.

It can also draft a reversible prompt patch proposal, so the next phase of worker education can prepare live prompt changes without applying them automatically.

The patch flow now supports:

- prompt patch proposal generation
- patched prompt preview generation
- patch approval request generation
- explicit proposal decision updates
- approval-gated live application

Start a long run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-long-run-supervisor.ps1 -Hours 10 -IntervalMinutes 15
```

On Windows, this launcher now registers a recurring Task Scheduler tick so unattended work can continue after the current Codex shell returns.

Inside each scheduled tick, the canonical continue loop runs in-process for reliability. The current unattended path processes the active worker roster as one multi-worker batch per cycle.

The recurring tick path now uses:

- `scripts/run-supervisor-tick.ps1`
- `runtime/state/long-run-supervisor.status.json`
- `runtime/state/long-run-supervisor.tick.lock`
- `runtime/logs/long-run-supervisor.jsonl`

The current verified behavior is:

- the tick acquires a lock
- runs one bounded cycle
- writes heartbeat and president inbox output
- records `supervisor_tick_ok`
- returns the status to `scheduled`
- clears the lock

If Task Scheduler cannot be queried from the current shell, `status-long-run-supervisor.ps1` now records:

- `scheduled_task_lookup_result = inaccessible`
- `scheduled_task_state = inaccessible`

instead of falsely claiming the scheduled task is missing.

## Local LLM Runtime

The local-model health path now uses:

- `runtime/config/local-llm-bindings.v1.json`
- `runtime/config/local-llm-runtime.v1.json`
- `scripts/check-local-llm-runtime.ps1`
- `runtime/state/local-llm-runtime.state.json`

`check-local-llm-runtime.ps1` now does three things:

- checks `GET /api/tags`
- records explicit runtime state and model availability
- if the endpoint is unreachable and auto-recovery is enabled, tries to launch `ollama.exe serve` from a known local path and re-checks the endpoint

The runtime state now records:

- `cli_resolution`
- `auto_recovery_enabled`
- `recovery_attempted`
- `recovery_succeeded`
- `recovery_completed_at`
- `recovery_detail`

This means the local runtime path is no longer just passive health reporting; it can attempt bounded self-recovery when Ollama is missing.

Check long-run status:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\status-long-run-supervisor.ps1
```

Operator reference:

- `WINDOWS_LONG_RUN_OPERATOR_RUNBOOK_V1.md`

Stop:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\stop-relay-bot.ps1
```

If trusted runtime files change intentionally, rerun `scripts/install-runtime-guard.ps1` before using the guarded control again.
