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
- `scripts/continue-bot-work.ps1`
- `scripts/write-bot-work-heartbeat.ps1`
- `scripts/write-president-message.ps1`
- `scripts/start-long-run-supervisor.ps1`
- `scripts/status-long-run-supervisor.ps1`
- `scripts/stop-long-run-supervisor.ps1`

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

Start a long run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-long-run-supervisor.ps1 -Hours 10 -IntervalMinutes 15
```

Check long-run status:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\status-long-run-supervisor.ps1
```

Stop:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\stop-relay-bot.ps1
```

If trusted runtime files change intentionally, rerun `scripts/install-runtime-guard.ps1` before using the guarded control again.
