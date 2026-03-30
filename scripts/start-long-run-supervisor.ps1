param(
  [int]$Hours = 10,
  [int]$IntervalMinutes = 15
)

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$StateRoot = Join-Path $ProjectRoot "runtime\state"
$PidPath = Join-Path $StateRoot "long-run-supervisor.pid"
$ScriptPath = Join-Path $PSScriptRoot "long-run-supervisor.ps1"

New-Item -ItemType Directory -Force -Path $StateRoot | Out-Null

if (Test-Path $PidPath) {
  $ExistingPid = Get-Content $PidPath -ErrorAction SilentlyContinue
  if ($ExistingPid) {
    $ExistingProcess = Get-Process -Id $ExistingPid -ErrorAction SilentlyContinue
    if ($ExistingProcess) {
      Write-Output "long-run supervisor is already running with PID $ExistingPid"
      exit 0
    }
  }
  Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
}

$PowerShellPath = (Get-Command powershell -ErrorAction Stop).Source
$StartInfo = New-Object System.Diagnostics.ProcessStartInfo
$StartInfo.FileName = $PowerShellPath
$StartInfo.Arguments = ('-ExecutionPolicy Bypass -File "{0}" -Hours {1} -IntervalMinutes {2}' -f $ScriptPath, $Hours, $IntervalMinutes)
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
  throw "long-run supervisor failed to start"
}

Write-Output "long-run supervisor started with PID $($Process.Id)"
