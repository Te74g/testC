param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PidPath = Join-Path $ProjectRoot "runtime\state\relay-bot.pid"

if (-not (Test-Path $PidPath)) {
  Write-Output "relay-bot is not running"
  exit 0
}

$RelayPid = Get-Content $PidPath -ErrorAction SilentlyContinue
if (-not $RelayPid) {
  Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
  Write-Output "relay-bot pid file was empty and has been cleared"
  exit 0
}

$Process = Get-Process -Id $RelayPid -ErrorAction SilentlyContinue
if (-not $Process) {
  Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
  Write-Output "relay-bot pid file was stale and has been cleared"
  exit 0
}

Stop-Process -Id $RelayPid -Force
Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
Write-Output "relay-bot stopped"
