param()

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "resolve-northbridge-path.ps1")

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$LocalStartScriptPath = Join-Path $PSScriptRoot "start-relay-bot.ps1"
$LocalRelayStatusPath = Join-Path $ProjectRoot "runtime\state\relay-bot.status.json"
if (Test-Path $LocalRelayStatusPath) {
  try {
    $LocalRelayStatus = Get-Content $LocalRelayStatusPath -Raw | ConvertFrom-Json
    if ($LocalRelayStatus -and $LocalRelayStatus.pid) {
      $ExistingProcess = Get-Process -Id $LocalRelayStatus.pid -ErrorAction SilentlyContinue
      if ($ExistingProcess) {
        Write-Output "relay bot already running with PID $($LocalRelayStatus.pid)"
        return
      }
    }
  } catch {
    # Fall through to guarded control recovery.
  }
}

$ControlPath = Resolve-NorthbridgeControlPath -ProjectRoot $ProjectRoot -RequireExisting
if (-not (Test-Path $ControlPath)) {
  $Candidates = Get-NorthbridgeRootCandidates -ProjectRoot $ProjectRoot
  throw "guarded relay control not found. candidates: $($Candidates -join ', ')"
}

function Invoke-GuardedControl {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  $Output = powershell -ExecutionPolicy Bypass -File $ControlPath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "guarded control failed for arguments: $($Arguments -join ' ')"
  }

  return $Output
}

function Start-RelayBotFallback {
  if (-not (Test-Path $LocalStartScriptPath)) {
    throw "local relay fallback script not found at $LocalStartScriptPath"
  }

  $Output = powershell -ExecutionPolicy Bypass -File $LocalStartScriptPath
  if ($LASTEXITCODE -ne 0) {
    throw "local relay fallback failed"
  }

  if ($Output) {
    $Output
  }
}

$StatusJson = $null
try {
  $StatusJson = Invoke-GuardedControl -Arguments @("-Action", "Status")
} catch {
  Start-RelayBotFallback
  Write-Output "relay bot started via local fallback after guarded control failure"
  return
}

if (-not $StatusJson) {
  Invoke-GuardedControl -Arguments @("-Action", "Start")
  Write-Output "relay bot started"
  return
}

try {
  $Status = $StatusJson | ConvertFrom-Json
} catch {
  Invoke-GuardedControl -Arguments @("-Action", "Start")
  Write-Output "relay bot started after unreadable status"
  return
}

if (-not $Status.pid) {
  Invoke-GuardedControl -Arguments @("-Action", "Start")
  Write-Output "relay bot started because pid was missing"
  return
}

$Process = Get-Process -Id $Status.pid -ErrorAction SilentlyContinue
if (-not $Process) {
  Invoke-GuardedControl -Arguments @("-Action", "Start")
  Write-Output "relay bot started because process was missing"
  return
}

Write-Output "relay bot already running with PID $($Status.pid)"
