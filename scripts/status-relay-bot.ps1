param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PidPath = Join-Path $ProjectRoot "runtime\state\relay-bot.pid"
$StatusPath = Join-Path $ProjectRoot "runtime\state\relay-bot.status.json"

$Status = "stopped"
$RelayPid = $null

if (Test-Path $PidPath) {
  $RelayPid = Get-Content $PidPath -ErrorAction SilentlyContinue
  if ($RelayPid) {
    $Process = Get-Process -Id $RelayPid -ErrorAction SilentlyContinue
    if ($Process) {
      $Status = "running"
    }
  }
}

Write-Output "status=$Status"
if ($RelayPid) {
  Write-Output "pid=$RelayPid"
}

if (Test-Path $StatusPath) {
  Get-Content $StatusPath
}
