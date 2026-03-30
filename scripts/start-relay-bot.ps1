param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$RuntimeRoot = Join-Path $ProjectRoot "runtime"
$LogsRoot = Join-Path $RuntimeRoot "logs"
$StateRoot = Join-Path $RuntimeRoot "state"
$PidPath = Join-Path $StateRoot "relay-bot.pid"
$BotPath = Join-Path $RuntimeRoot "relay-bot.js"
$NodePath = (Get-Command node).Source

New-Item -ItemType Directory -Force -Path $LogsRoot | Out-Null
New-Item -ItemType Directory -Force -Path $StateRoot | Out-Null

if (Test-Path $PidPath) {
  $ExistingPid = Get-Content $PidPath -ErrorAction SilentlyContinue
  if ($ExistingPid) {
    $ExistingProcess = Get-Process -Id $ExistingPid -ErrorAction SilentlyContinue
    if ($ExistingProcess) {
      Write-Output "relay-bot is already running with PID $ExistingPid"
      exit 0
    }
  }
  Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
}

$StartInfo = New-Object System.Diagnostics.ProcessStartInfo
$StartInfo.FileName = $NodePath
$StartInfo.Arguments = ('"{0}"' -f $BotPath)
$StartInfo.WorkingDirectory = $ProjectRoot
$StartInfo.UseShellExecute = $false
$StartInfo.CreateNoWindow = $true

$Process = New-Object System.Diagnostics.Process
$Process.StartInfo = $StartInfo
$null = $Process.Start()

Set-Content -Path $PidPath -Value $Process.Id -Encoding ascii
Start-Sleep -Milliseconds 800

$RunningProcess = Get-Process -Id $Process.Id -ErrorAction SilentlyContinue
if (-not $RunningProcess) {
  throw "relay-bot failed to start"
}

Write-Output "relay-bot started with PID $($Process.Id)"
