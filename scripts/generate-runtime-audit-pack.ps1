param(
  [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

$StatusPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.status.json"
$HeartbeatPath = Join-Path $ProjectRoot "runtime\state\work-heartbeat\latest.json"
$LocalRuntimePath = Join-Path $ProjectRoot "runtime\state\local-llm-runtime.state.json"
$LogPath = Join-Path $ProjectRoot "runtime\logs\long-run-supervisor.jsonl"

if (-not $OutputDir) {
  $OutputDir = Join-Path $ProjectRoot "products\runtime-audit-studio\reports\latest"
}

function Write-Utf8NoBomFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$Content
  )

  $Directory = Split-Path -Parent $Path
  if ($Directory) {
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }

  $Encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $Encoding)
}

function Read-JsonFile {
  param([string]$Path)
  if (-not (Test-Path $Path)) {
    throw "Required JSON file not found: $Path"
  }
  return Get-Content $Path -Raw | ConvertFrom-Json
}

function Get-LastTickEvents {
  param(
    [string]$Path,
    [int]$MaxItems = 3
  )

  if (-not (Test-Path $Path)) {
    return @()
  }

  $Lines = Get-Content $Path | Where-Object { $_.Trim() }
  $Parsed = foreach ($Line in $Lines) {
    try {
      $Obj = $Line | ConvertFrom-Json
      if ($Obj.event -eq "supervisor_tick_ok") {
        $Obj
      }
    } catch {
    }
  }

  return @($Parsed | Sort-Object timestamp -Descending | Select-Object -First $MaxItems)
}

$Status = Read-JsonFile -Path $StatusPath
$Heartbeat = Read-JsonFile -Path $HeartbeatPath
$LocalRuntime = Read-JsonFile -Path $LocalRuntimePath
$RecentTicks = Get-LastTickEvents -Path $LogPath -MaxItems 3

$SupervisorHealthy = $false
if ($Status.state -eq "scheduled" -or $Status.state -eq "running") {
  if ($Status.cycle_count -ge 3) {
    $SupervisorHealthy = $true
  }
}

$LocalHealthy = ($LocalRuntime.status -eq "ready" -and $LocalRuntime.reachable -and $LocalRuntime.model_available)
$RecoveryState = if ($LocalRuntime.recovery_attempted) {
  if ($LocalRuntime.recovery_succeeded) { "recovered" } else { "attempted_but_failed" }
} elseif ($LocalRuntime.auto_recovery_enabled) {
  "armed_not_used"
} else {
  "disabled"
}

$TickSummary = if ($RecentTicks.Count -gt 0) {
  ($RecentTicks | ForEach-Object {
    "- cycle $($_.details.cycle): $($_.timestamp)"
  }) -join "`n"
} else {
  "- no recent supervisor_tick_ok events found"
}

$Recommendation = if ($SupervisorHealthy -and $LocalHealthy) {
  "Keep the current Task Scheduler recurring tick plus in-process PowerShell supervisor as the operating baseline."
} elseif (-not $SupervisorHealthy -and $LocalHealthy) {
  "Do not trust unattended execution yet. Repair supervisor continuity before expanding usage."
} elseif ($SupervisorHealthy -and -not $LocalHealthy) {
  "Keep the unattended shell, but block prompt-patch work until the local runtime is healthy."
} else {
  "Treat the current system as a lab, not an operating baseline. Fix both unattended continuity and local runtime health first."
}

$RiskLines = @()
if (-not $SupervisorHealthy) {
  $RiskLines += "- unattended supervisor health is not yet strong enough"
}
if (-not $LocalHealthy) {
  $RiskLines += "- local model runtime is not healthy enough for reliable worker evaluation"
}
if ($Status.scheduled_task_lookup_result -eq "inaccessible") {
  $RiskLines += "- Task Scheduler state cannot be directly queried from the current shell, so status proof relies on heartbeat and logs"
}
if ($RiskLines.Count -eq 0) {
  $RiskLines += "- no blocking runtime risk is visible in the current snapshot"
}

$Report = @"
# Runtime Audit Pack

## Executive Summary

- audit timestamp: $(Get-Date -Format o)
- unattended supervisor state: $($Status.state)
- supervisor cycle count: $($Status.cycle_count)
- local runtime status: $($LocalRuntime.status)
- local runtime recovery state: $RecoveryState
- recommendation: $Recommendation

## Snapshot

- supervisor started_at: $($Status.started_at)
- supervisor end_at: $($Status.end_at)
- supervisor last_cycle_at: $($Status.last_cycle_at)
- supervisor last_result: $($Status.last_result)
- effective worker lanes: $($Heartbeat.current_effective_worker_lanes)
- approved worker slots: $($Heartbeat.approved_parallel_worker_slots)
- local runtime base_url: $($LocalRuntime.base_url)
- local runtime default_model: $($LocalRuntime.default_model)
- local runtime reachable: $($LocalRuntime.reachable)
- local runtime model_available: $($LocalRuntime.model_available)

## Evidence

### Recent Successful Ticks

$TickSummary

### Current Health Signals

- heartbeat timestamp: $($Heartbeat.timestamp)
- local evaluation run count: $($Heartbeat.local_evaluation_run_count)
- northbridge dream status: $($Heartbeat.northbridge_dream_last_status)
- scheduled dream status: $($Heartbeat.scheduled_jobs_northbridge_dream_status)
- task lookup result: $($Status.scheduled_task_lookup_result)
- task lookup state: $($Status.scheduled_task_state)

## Risks

$($RiskLines -join "`n")

## Operational Recommendation

$Recommendation

## Next Actions

1. Keep collecting fresh supervisor tick evidence and heartbeat movement.
2. Exercise Ollama auto-recovery on a controlled failure, then re-run this audit.
3. Only after that, promote this runtime from internal baseline to client-facing operating claim.
"@

$Generation = [ordered]@{
  generated_at = (Get-Date).ToString("o")
  status_path = $StatusPath.Replace($ProjectRoot + "\", "")
  heartbeat_path = $HeartbeatPath.Replace($ProjectRoot + "\", "")
  local_runtime_path = $LocalRuntimePath.Replace($ProjectRoot + "\", "")
  log_path = $LogPath.Replace($ProjectRoot + "\", "")
  supervisor_healthy = $SupervisorHealthy
  local_runtime_healthy = $LocalHealthy
  recommendation = $Recommendation
}

$ReportPath = Join-Path $OutputDir "runtime-audit.md"
$GenerationPath = Join-Path $OutputDir "generation.json"

Write-Utf8NoBomFile -Path $ReportPath -Content ($Report.TrimStart() + "`n")
Write-Utf8NoBomFile -Path $GenerationPath -Content (($Generation | ConvertTo-Json -Depth 10) + "`n")

Write-Output "runtime audit pack generated"
Write-Output ("report: " + $ReportPath.Replace($ProjectRoot + "\", ""))
