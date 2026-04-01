param(
  [double]$Hours = 0,
  [int]$IntervalMinutes = 0
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$StateRoot = Join-Path $ProjectRoot "runtime\state"
$RuntimeSettingsPath = Join-Path $ProjectRoot "runtime\config\runtime-settings.v1.json"
$StatusPath = Join-Path $StateRoot "long-run-supervisor.status.json"
$TickScriptPath = Join-Path $PSScriptRoot "run-supervisor-tick.ps1"
$TaskName = "NorthbridgeSupervisorTick"
$FallbackTaskName = "NorthbridgeLongRunSupervisor"

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

function Write-Status {
  param(
    [string]$StartedAt,
    [string]$EndAt,
    [int]$IntervalMinutesValue,
    [int]$ApprovedParallelWorkerSlots,
    [int]$CurrentEffectiveWorkerLanes
  )

  New-Item -ItemType Directory -Force -Path $StateRoot | Out-Null
  [pscustomobject]@{
    pid = 0
    state = "scheduled"
    started_at = $StartedAt
    end_at = $EndAt
    interval_minutes = $IntervalMinutesValue
    approved_parallel_worker_slots = $ApprovedParallelWorkerSlots
    current_effective_worker_lanes = $CurrentEffectiveWorkerLanes
    cycle_count = 0
    last_cycle_at = ""
    current_cycle_started_at = ""
    last_result = "scheduled"
    last_progress_at = $StartedAt
    last_heartbeat = $StartedAt
    scheduler_task_name = $TaskName
    scheduler_mode = "scheduled_tick"
  } | ConvertTo-Json -Depth 10 | Set-Content -Path $StatusPath -Encoding UTF8
}

$RuntimeSettings = Read-RuntimeSettings
if ($Hours -le 0) {
  $Hours = [double]$RuntimeSettings.default_supervisor_hours
  if ($Hours -le 0) { $Hours = 20 }
}
if ($IntervalMinutes -le 0) {
  $IntervalMinutes = [int]$RuntimeSettings.default_interval_minutes
  if ($IntervalMinutes -le 0) { $IntervalMinutes = 5 }
}

$ApprovedParallelWorkerSlots = [int]$RuntimeSettings.approved_parallel_worker_slots
if ($ApprovedParallelWorkerSlots -le 0) { $ApprovedParallelWorkerSlots = 10 }
$CurrentEffectiveWorkerLanes = [int]$RuntimeSettings.current_effective_worker_lanes
if ($CurrentEffectiveWorkerLanes -le 0) { $CurrentEffectiveWorkerLanes = 1 }

$PowerShellPath = (Get-Command powershell -ErrorAction Stop).Source
$StartedAt = [DateTimeOffset]::Now.ToString("o")
$EndAtDate = (Get-Date).AddHours($Hours)
$EndAt = ([DateTimeOffset]$EndAtDate).ToString("o")

if ($null -eq (Get-Command Register-ScheduledTask -ErrorAction SilentlyContinue)) {
  throw "scheduled tasks are required for the recurring supervisor tick mode"
}

try {
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
} catch {
}
try {
  Unregister-ScheduledTask -TaskName $FallbackTaskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
} catch {
}

Write-Status `
  -StartedAt $StartedAt `
  -EndAt $EndAt `
  -IntervalMinutesValue $IntervalMinutes `
  -ApprovedParallelWorkerSlots $ApprovedParallelWorkerSlots `
  -CurrentEffectiveWorkerLanes $CurrentEffectiveWorkerLanes

$Arguments = @(
  "-NoProfile",
  "-NonInteractive",
  "-ExecutionPolicy", "Bypass",
  "-File", ('"{0}"' -f $TickScriptPath)
) -join " "

$Trigger = New-ScheduledTaskTrigger `
  -Once `
  -At ((Get-Date).AddMinutes(1)) `
  -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) `
  -RepetitionDuration (New-TimeSpan -Hours $Hours)

$Action = New-ScheduledTaskAction -Execute $PowerShellPath -Argument $Arguments
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask `
  -TaskName $TaskName `
  -Action $Action `
  -Trigger $Trigger `
  -Settings $Settings `
  -Description "Northbridge recurring supervisor tick" `
  -Force | Out-Null

Start-ScheduledTask -TaskName $TaskName

Write-Output "long-run supervisor started via recurring scheduled task $TaskName"
Write-Output "mode=scheduled_tick"
Write-Output "interval_minutes=$IntervalMinutes"
Write-Output "end_at=$EndAt"
