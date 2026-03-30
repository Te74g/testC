param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$StatusPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.status.json"
$PidPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.pid"

$Status = "stopped"
$SupervisorPid = $null

if (Test-Path $PidPath) {
  $SupervisorPid = Get-Content $PidPath -ErrorAction SilentlyContinue
  if ($SupervisorPid) {
    $Process = Get-Process -Id $SupervisorPid -ErrorAction SilentlyContinue
    if ($Process) {
      $Status = "running"
    } else {
      Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
      $SupervisorPid = $null
    }
  }
}

Write-Output "status=$Status"
if ($SupervisorPid) {
  Write-Output "pid=$SupervisorPid"
}

if (Test-Path $StatusPath) {
  Get-Content $StatusPath
}
