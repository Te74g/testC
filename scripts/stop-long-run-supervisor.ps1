param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PidPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.pid"

if (-not (Test-Path $PidPath)) {
  Write-Output "long-run supervisor is not running"
  exit 0
}

$SupervisorPid = Get-Content $PidPath -ErrorAction SilentlyContinue
if (-not $SupervisorPid) {
  Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
  Write-Output "long-run supervisor pid file was empty and has been cleared"
  exit 0
}

$Process = Get-Process -Id $SupervisorPid -ErrorAction SilentlyContinue
if (-not $Process) {
  Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
  Write-Output "long-run supervisor pid file was stale and has been cleared"
  exit 0
}

Stop-Process -Id $SupervisorPid -Force
Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
Write-Output "long-run supervisor stopped"
