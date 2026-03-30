param()

. (Join-Path $PSScriptRoot "resolve-northbridge-path.ps1")

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ControlPath = Resolve-NorthbridgeControlPath -ProjectRoot $ProjectRoot -RequireExisting
if (-not (Test-Path $ControlPath)) {
  $Candidates = Get-NorthbridgeRootCandidates -ProjectRoot $ProjectRoot
  throw "guarded relay control not found. candidates: $($Candidates -join ', ')"
}

$StatusJson = powershell -ExecutionPolicy Bypass -File $ControlPath -Action Status

if ($LASTEXITCODE -ne 0 -or -not $StatusJson) {
  powershell -ExecutionPolicy Bypass -File $ControlPath -Action Start
  Write-Output "relay bot started"
  exit 0
}

try {
  $Status = $StatusJson | ConvertFrom-Json
} catch {
  powershell -ExecutionPolicy Bypass -File $ControlPath -Action Start
  Write-Output "relay bot started after unreadable status"
  exit 0
}

if (-not $Status.pid) {
  powershell -ExecutionPolicy Bypass -File $ControlPath -Action Start
  Write-Output "relay bot started because pid was missing"
  exit 0
}

$Process = Get-Process -Id $Status.pid -ErrorAction SilentlyContinue
if (-not $Process) {
  powershell -ExecutionPolicy Bypass -File $ControlPath -Action Start
  Write-Output "relay bot started because process was missing"
  exit 0
}

Write-Output "relay bot already running with PID $($Status.pid)"
