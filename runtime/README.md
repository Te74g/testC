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

Stop:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\stop-relay-bot.ps1
```
