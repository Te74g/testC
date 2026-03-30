param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$InboxRoot = Join-Path $ProjectRoot "runtime\inbox\president"
$WorkerLabStatePath = Join-Path $ProjectRoot "runtime\state\worker-lab.state.json"
$HeartbeatPath = Join-Path $ProjectRoot "runtime\state\work-heartbeat\latest.json"
$SupervisorStatusPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.status.json"

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

$WorkerLabState = $null
if (Test-Path $WorkerLabStatePath) {
  $WorkerLabState = Get-Content $WorkerLabStatePath -Raw | ConvertFrom-Json
}

$Heartbeat = $null
if (Test-Path $HeartbeatPath) {
  $Heartbeat = Get-Content $HeartbeatPath -Raw | ConvertFrom-Json
}

$SupervisorStatus = $null
if (Test-Path $SupervisorStatusPath) {
  $SupervisorStatus = Get-Content $SupervisorStatusPath -Raw | ConvertFrom-Json
}

$Timestamp = Get-Date
$Stamp = $Timestamp.ToString("yyyyMMdd-HHmmss")
$MessagePath = Join-Path $InboxRoot ("{0}-northbridge-president.md" -f $Stamp)

$LastWorkerKey = if ($WorkerLabState) { [string]$WorkerLabState.last_worker_key } else { "unknown" }
$PrototypeCount = if ($Heartbeat) { [int]$Heartbeat.prototype_count } else { 0 }
$EvaluationCount = if ($Heartbeat) { [int]$Heartbeat.evaluation_count } else { 0 }
$ReviewCount = if ($Heartbeat) { [int]$Heartbeat.promotion_review_count } else { 0 }
$LabPlanCount = if ($Heartbeat) { [int]$Heartbeat.worker_lab_plan_count } else { 0 }
$SupervisorCycle = if ($SupervisorStatus) { [int]$SupervisorStatus.cycle_count } else { 0 }
$SupervisorEnd = if ($SupervisorStatus) { [string]$SupervisorStatus.end_at } else { "" }

$Message = @"
# Northbridge President Inbox

## Message Meta

- created_at: {0}
- sender: worker continuity bot
- target: Northbridge Systems president

## Cycle Summary

- supervisor_cycle_count: {1}
- latest_worker_lab_target: {2}
- prototype_count: {3}
- evaluation_count: {4}
- promotion_review_count: {5}
- worker_lab_plan_count: {6}

## Meaning

The unattended loop is active and has prepared the latest worker iteration focus for `{2}`.

## Recommended Executive Read

- inspect the newest worker-lab note for `{2}`
- decide whether to keep the current prompt or draft a revised candidate
- if the loop looks idle, verify that a new worker-lab artifact appeared this cycle

## Supervisor Window

- expected_end_at: {7}

"@ -f `
  $Timestamp.ToString("o"),
  $SupervisorCycle,
  $LastWorkerKey,
  $PrototypeCount,
  $EvaluationCount,
  $ReviewCount,
  $LabPlanCount,
  $SupervisorEnd

Write-Utf8NoBomFile -Path $MessagePath -Content ($Message.TrimStart() + "`n")
Write-Output "created president inbox message"
