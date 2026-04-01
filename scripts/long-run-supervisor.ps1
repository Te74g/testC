param(
  [double]$Hours = 0,
  [int]$IntervalMinutes = 0
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$StateRoot = Join-Path $ProjectRoot "runtime\state"
$LogsRoot = Join-Path $ProjectRoot "runtime\logs"
$RuntimeSettingsPath = Join-Path $ProjectRoot "runtime\config\runtime-settings.v1.json"
$StatusPath = Join-Path $StateRoot "long-run-supervisor.status.json"
$PidPath = Join-Path $StateRoot "long-run-supervisor.pid"
$LogPath = Join-Path $LogsRoot "long-run-supervisor.jsonl"

function Ensure-Directory {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  New-Item -ItemType Directory -Force -Path $Path | Out-Null
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

function Write-JsonFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [object]$Value
  )

  Ensure-Directory -Path (Split-Path -Parent $Path)
  $Value | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -Encoding UTF8
}

function Write-JsonLine {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Event,

    [Parameter(Mandatory = $true)]
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

function Write-SupervisorStatus {
  param(
    [Parameter(Mandatory = $true)]
    [string]$State,

    [Parameter(Mandatory = $true)]
    [string]$StartedAt,

    [Parameter(Mandatory = $true)]
    [string]$EndAt,

    [Parameter(Mandatory = $true)]
    [int]$IntervalMinutesValue,

    [Parameter(Mandatory = $true)]
    [int]$ApprovedParallelWorkerSlots,

    [Parameter(Mandatory = $true)]
    [int]$CurrentEffectiveWorkerLanes,

    [Parameter(Mandatory = $true)]
    [int]$CycleCount,

    [string]$LastCycleAt = "",

    [string]$CurrentCycleStartedAt = "",

    [string]$LastProgressAt = "",

    [Parameter(Mandatory = $true)]
    [string]$LastResult
  )

  Write-JsonFile -Path $StatusPath -Value ([pscustomobject]@{
    pid = $PID
    state = $State
    started_at = $StartedAt
    end_at = $EndAt
    interval_minutes = $IntervalMinutesValue
    approved_parallel_worker_slots = $ApprovedParallelWorkerSlots
    current_effective_worker_lanes = $CurrentEffectiveWorkerLanes
    cycle_count = $CycleCount
    last_cycle_at = $LastCycleAt
    current_cycle_started_at = $CurrentCycleStartedAt
    last_result = $LastResult
    last_progress_at = $(if ($LastProgressAt) { $LastProgressAt } else { [DateTimeOffset]::Now.ToString("o") })
    last_heartbeat = [DateTimeOffset]::Now.ToString("o")
  })
}

function Invoke-LoopScript {
  param(
    [Parameter(Mandatory = $true)]
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

$RuntimeSettings = Read-RuntimeSettings
if ($Hours -le 0) {
  $Hours = [double]($RuntimeSettings.default_supervisor_hours)
  if ($Hours -le 0) {
    $Hours = 20
  }
}

if ($IntervalMinutes -le 0) {
  $IntervalMinutes = [int]($RuntimeSettings.default_interval_minutes)
  if ($IntervalMinutes -le 0) {
    $IntervalMinutes = 5
  }
}

$ApprovedParallelWorkerSlots = [int]($RuntimeSettings.approved_parallel_worker_slots)
if ($ApprovedParallelWorkerSlots -le 0) {
  $ApprovedParallelWorkerSlots = 10
}

$CurrentEffectiveWorkerLanes = [int]($RuntimeSettings.current_effective_worker_lanes)
if ($CurrentEffectiveWorkerLanes -le 0) {
  $CurrentEffectiveWorkerLanes = 1
}

$StartedAt = [DateTimeOffset]::Now.ToString("o")
$EndAtDate = (Get-Date).AddHours($Hours)
$EndAt = [DateTimeOffset]$EndAtDate | ForEach-Object { $_.ToString("o") }
$CycleCount = 0

Set-Content -Path $PidPath -Value $PID -Encoding ASCII
Write-SupervisorStatus `
  -State "running" `
  -StartedAt $StartedAt `
  -EndAt $EndAt `
  -IntervalMinutesValue $IntervalMinutes `
  -ApprovedParallelWorkerSlots $ApprovedParallelWorkerSlots `
  -CurrentEffectiveWorkerLanes $CurrentEffectiveWorkerLanes `
  -CycleCount $CycleCount `
  -LastResult "starting"

Write-JsonLine -Event "supervisor_started" -Details ([pscustomobject]@{
  hours = $Hours
  interval_minutes = $IntervalMinutes
  approved_parallel_worker_slots = $ApprovedParallelWorkerSlots
  current_effective_worker_lanes = $CurrentEffectiveWorkerLanes
  end_at = $EndAt
  engine = "powershell"
})

try {
  while ((Get-Date) -lt $EndAtDate) {
    $CycleCount += 1
    $CycleAt = [DateTimeOffset]::Now.ToString("o")
    Write-SupervisorStatus `
      -State "running" `
      -StartedAt $StartedAt `
      -EndAt $EndAt `
      -IntervalMinutesValue $IntervalMinutes `
      -ApprovedParallelWorkerSlots $ApprovedParallelWorkerSlots `
      -CurrentEffectiveWorkerLanes $CurrentEffectiveWorkerLanes `
      -CycleCount $CycleCount `
      -LastCycleAt $CycleAt `
      -CurrentCycleStartedAt $CycleAt `
      -LastProgressAt $CycleAt `
      -LastResult "running_cycle"

    try {
      $ContinueOutput = Invoke-LoopScript -ScriptName "continue-bot-work.ps1" -Arguments @("-InProcess")
      $HeartbeatOutput = Invoke-LoopScript -ScriptName "write-bot-work-heartbeat.ps1"
      $ProgressAt = [DateTimeOffset]::Now.ToString("o")

      Write-JsonLine -Event "supervisor_cycle_ok" -Details ([pscustomobject]@{
        cycle = $CycleCount
        cycle_at = $CycleAt
        continue_output = $ContinueOutput
        heartbeat_output = $HeartbeatOutput
      })

      Write-SupervisorStatus `
        -State "running" `
        -StartedAt $StartedAt `
        -EndAt $EndAt `
        -IntervalMinutesValue $IntervalMinutes `
        -ApprovedParallelWorkerSlots $ApprovedParallelWorkerSlots `
        -CurrentEffectiveWorkerLanes $CurrentEffectiveWorkerLanes `
        -CycleCount $CycleCount `
        -LastCycleAt $CycleAt `
        -CurrentCycleStartedAt "" `
        -LastProgressAt $ProgressAt `
        -LastResult "ok"
    } catch {
      $MessageLines = @($_.Exception.Message -split "`r?`n" | Where-Object { $_ -ne "" })
      $ProgressAt = [DateTimeOffset]::Now.ToString("o")

      Write-JsonLine -Event "supervisor_cycle_failed" -Details ([pscustomobject]@{
        cycle = $CycleCount
        cycle_at = $CycleAt
        error = $MessageLines[0]
        output = @($MessageLines | Select-Object -Skip 1)
      })

      Write-SupervisorStatus `
        -State "running" `
        -StartedAt $StartedAt `
        -EndAt $EndAt `
        -IntervalMinutesValue $IntervalMinutes `
        -ApprovedParallelWorkerSlots $ApprovedParallelWorkerSlots `
        -CurrentEffectiveWorkerLanes $CurrentEffectiveWorkerLanes `
        -CycleCount $CycleCount `
        -LastCycleAt $CycleAt `
        -CurrentCycleStartedAt "" `
        -LastProgressAt $ProgressAt `
        -LastResult "failed"
    }

    if ((Get-Date) -ge $EndAtDate) {
      break
    }

    Start-Sleep -Seconds ([Math]::Max(1, ($IntervalMinutes * 60)))
  }

  Write-SupervisorStatus `
    -State "completed" `
    -StartedAt $StartedAt `
    -EndAt $EndAt `
    -IntervalMinutesValue $IntervalMinutes `
    -ApprovedParallelWorkerSlots $ApprovedParallelWorkerSlots `
    -CurrentEffectiveWorkerLanes $CurrentEffectiveWorkerLanes `
    -CycleCount $CycleCount `
    -LastCycleAt ([DateTimeOffset]::Now.ToString("o")) `
    -CurrentCycleStartedAt "" `
    -LastResult "completed"

  Write-JsonLine -Event "supervisor_completed" -Details ([pscustomobject]@{
    cycle_count = $CycleCount
    engine = "powershell"
  })
} catch {
  $FatalAt = [DateTimeOffset]::Now.ToString("o")
  Write-SupervisorStatus `
    -State "failed" `
    -StartedAt $StartedAt `
    -EndAt $EndAt `
    -IntervalMinutesValue $IntervalMinutes `
    -ApprovedParallelWorkerSlots $ApprovedParallelWorkerSlots `
    -CurrentEffectiveWorkerLanes $CurrentEffectiveWorkerLanes `
    -CycleCount $CycleCount `
    -LastCycleAt $FatalAt `
    -CurrentCycleStartedAt "" `
    -LastProgressAt $FatalAt `
    -LastResult "fatal"

  Write-JsonLine -Event "supervisor_fatal" -Details ([pscustomobject]@{
    cycle = $CycleCount
    fatal_at = $FatalAt
    error = $_.Exception.Message
    engine = "powershell"
  })

  throw
} finally {
  if (Test-Path $PidPath) {
    Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
  }
}
