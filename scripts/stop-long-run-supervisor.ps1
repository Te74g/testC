param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$StatusPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.status.json"
$LockPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.tick.lock"
$TaskName = "NorthbridgeSupervisorTick"
$LegacyTaskName = "NorthbridgeLongRunSupervisor"

if ($null -ne (Get-Command Stop-ScheduledTask -ErrorAction SilentlyContinue)) {
  try {
    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
  } catch {
  }
}
if ($null -ne (Get-Command Unregister-ScheduledTask -ErrorAction SilentlyContinue)) {
  try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
  } catch {
  }
  try {
    Unregister-ScheduledTask -TaskName $LegacyTaskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
  } catch {
  }
}

if (Test-Path $LockPath) {
  Remove-Item $LockPath -Force -ErrorAction SilentlyContinue
}

if (Test-Path $StatusPath) {
  $Status = Get-Content $StatusPath -Raw | ConvertFrom-Json
  $Status.state = "stopped"
  $Status.last_result = "stopped_by_operator"
  $Status.last_heartbeat = [DateTimeOffset]::Now.ToString("o")
  $Status.current_cycle_started_at = ""
  $Status | ConvertTo-Json -Depth 10 | Set-Content -Path $StatusPath -Encoding UTF8
}

Write-Output "long-run supervisor stopped"
