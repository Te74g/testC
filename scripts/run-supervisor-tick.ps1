param()

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$StateRoot = Join-Path $ProjectRoot "runtime\state"
$LogsRoot = Join-Path $ProjectRoot "runtime\logs"
$StatusPath = Join-Path $StateRoot "long-run-supervisor.status.json"
$LockPath = Join-Path $StateRoot "long-run-supervisor.tick.lock"
$LogPath = Join-Path $LogsRoot "long-run-supervisor.jsonl"
$RuntimeSettingsPath = Join-Path $ProjectRoot "runtime\config\runtime-settings.v1.json"

function Ensure-Directory {
  param([string]$Path)
  New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Write-JsonFile {
  param(
    [string]$Path,
    [object]$Value
  )

  Ensure-Directory -Path (Split-Path -Parent $Path)
  $Value | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -Encoding UTF8
}

function Write-JsonLine {
  param(
    [string]$Event,
    [object]$Details
  )

  Ensure-Directory -Path $LogsRoot
  $Entry = [pscustomobject]@{
    timestamp = [DateTimeOffset]::Now.ToString("o")
    event = $Event
    details = $Details
  }
  $Entry | ConvertTo-Json -Depth 10 -Compress | Add-Content -Path $LogPath -Encoding UTF8
}

function Read-RuntimeSettings {
  if (-not (Test-Path $RuntimeSettingsPath)) {
    return [pscustomobject]@{
      default_supervisor_hours = 20
      default_interval_minutes = 5
      approved_parallel_worker_slots = 10
      current_effective_worker_lanes = 1
    }
  }

  return Get-Content $RuntimeSettingsPath -Raw | ConvertFrom-Json
}

function Read-Status {
  if (-not (Test-Path $StatusPath)) {
    return $null
  }

  return Get-Content $StatusPath -Raw | ConvertFrom-Json
}

function Invoke-LoopScript {
  param(
    [string]$ScriptName,
    [string[]]$Arguments = @()
  )

  $ScriptPath = Join-Path $PSScriptRoot $ScriptName
  try {
    if ($Arguments.Count -eq 1 -and $Arguments[0] -eq "-InProcess") {
      $Output = & $ScriptPath -InProcess 2>&1
    } elseif ($Arguments.Count -eq 0) {
      $Output = & $ScriptPath 2>&1
    } else {
      throw "unsupported in-process argument pattern"
    }
  } catch {
    $Lines = @()
    if ($Output) {
      $Lines = @($Output | ForEach-Object { "$_" })
    }
    $Lines += $_.Exception.Message
    throw [System.Exception]::new("$ScriptName failed`n$($Lines -join "`n")")
  }

  if (-not $Output) {
    return @()
  }

  return @($Output | ForEach-Object { "$_" })
}

Ensure-Directory -Path $StateRoot
Ensure-Directory -Path $LogsRoot

$ExistingStatus = Read-Status
if (-not $ExistingStatus) {
  throw "long-run supervisor status is missing; start-long-run-supervisor.ps1 must initialize it first"
}

$Now = [DateTimeOffset]::Now
$NowIso = $Now.ToString("o")

if (Test-Path $LockPath) {
  $Lock = Get-Content $LockPath -Raw | ConvertFrom-Json
  $LockedAt = $null
  try {
    $LockedAt = [DateTimeOffset]::Parse($Lock.locked_at)
  } catch {
  }

  if ($LockedAt -and (($Now - $LockedAt).TotalMinutes -lt 30)) {
    Write-JsonLine -Event "supervisor_tick_skipped_locked" -Details ([pscustomobject]@{
      locked_at = $Lock.locked_at
      lock_pid = $Lock.pid
    })
    exit 0
  }

  Remove-Item $LockPath -Force -ErrorAction SilentlyContinue
}

Write-JsonFile -Path $LockPath -Value ([pscustomobject]@{
  pid = $PID
  locked_at = $NowIso
})

try {
  $RuntimeSettings = Read-RuntimeSettings
  $ApprovedParallelWorkerSlots = [int]$RuntimeSettings.approved_parallel_worker_slots
  if ($ApprovedParallelWorkerSlots -le 0) { $ApprovedParallelWorkerSlots = 10 }
  $CurrentEffectiveWorkerLanes = [int]$RuntimeSettings.current_effective_worker_lanes
  if ($CurrentEffectiveWorkerLanes -le 0) { $CurrentEffectiveWorkerLanes = 1 }

  $EndAt = [DateTimeOffset]::Parse($ExistingStatus.end_at)
  if ($Now -ge $EndAt) {
    $ExistingStatus.state = "completed"
    $ExistingStatus.last_result = "completed"
    $ExistingStatus.last_heartbeat = $NowIso
    $ExistingStatus.last_progress_at = $NowIso
    Write-JsonFile -Path $StatusPath -Value $ExistingStatus
    Write-JsonLine -Event "supervisor_tick_completed_window" -Details ([pscustomobject]@{
      now = $NowIso
      end_at = $ExistingStatus.end_at
    })
    exit 0
  }

  $CycleCount = [int]$ExistingStatus.cycle_count + 1
  $ExistingStatus.pid = $PID
  $ExistingStatus.state = "running"
  $ExistingStatus.cycle_count = $CycleCount
  $ExistingStatus.last_cycle_at = $NowIso
  $ExistingStatus.current_cycle_started_at = $NowIso
  $ExistingStatus.last_progress_at = $NowIso
  $ExistingStatus.last_result = "running_cycle"
  $ExistingStatus.last_heartbeat = $NowIso
  $ExistingStatus.approved_parallel_worker_slots = $ApprovedParallelWorkerSlots
  $ExistingStatus.current_effective_worker_lanes = $CurrentEffectiveWorkerLanes
  Write-JsonFile -Path $StatusPath -Value $ExistingStatus

  $ContinueOutput = Invoke-LoopScript -ScriptName "continue-bot-work.ps1" -Arguments @("-InProcess")
  $HeartbeatOutput = Invoke-LoopScript -ScriptName "write-bot-work-heartbeat.ps1"
  $ProgressAt = [DateTimeOffset]::Now.ToString("o")

  $ExistingStatus.pid = $PID
  $ExistingStatus.state = "scheduled"
  $ExistingStatus.cycle_count = $CycleCount
  $ExistingStatus.last_cycle_at = $NowIso
  $ExistingStatus.current_cycle_started_at = ""
  $ExistingStatus.last_progress_at = $ProgressAt
  $ExistingStatus.last_result = "ok"
  $ExistingStatus.last_heartbeat = $ProgressAt
  Write-JsonFile -Path $StatusPath -Value $ExistingStatus

  Write-JsonLine -Event "supervisor_tick_ok" -Details ([pscustomobject]@{
    cycle = $CycleCount
    cycle_at = $NowIso
    continue_output = $ContinueOutput
    heartbeat_output = $HeartbeatOutput
  })
} catch {
  $FailedAt = [DateTimeOffset]::Now.ToString("o")
  $FailureStatus = Read-Status
  if ($FailureStatus) {
    $FailureStatus.pid = $PID
    $FailureStatus.state = "scheduled"
    $FailureStatus.current_cycle_started_at = ""
    $FailureStatus.last_progress_at = $FailedAt
    $FailureStatus.last_result = "failed"
    $FailureStatus.last_heartbeat = $FailedAt
    Write-JsonFile -Path $StatusPath -Value $FailureStatus
  }

  Write-JsonLine -Event "supervisor_tick_failed" -Details ([pscustomobject]@{
    error = $_.Exception.Message
    failed_at = $FailedAt
  })
  throw
} finally {
  if (Test-Path $LockPath) {
    Remove-Item $LockPath -Force -ErrorAction SilentlyContinue
  }
}
