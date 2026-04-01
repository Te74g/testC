param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$InboxRoot = Join-Path $ProjectRoot "runtime\inbox\president"
$WorkerLabStatePath = Join-Path $ProjectRoot "runtime\state\worker-lab.state.json"
$HeartbeatPath = Join-Path $ProjectRoot "runtime\state\work-heartbeat\latest.json"
$SupervisorStatusPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.status.json"
$PatchBoardPath = Join-Path $ProjectRoot "workers\review-board\latest-patch-review-board.md"
$DecisionBriefPath = Join-Path $ProjectRoot "workers\decision-briefs\latest-worker-patch-decision-brief.md"
$LivePatchReadinessPath = Join-Path $ProjectRoot "workers\live-patch-readiness\latest-primary-live-patch-readiness.md"
$LivePatchPackPath = Join-Path $ProjectRoot "workers\live-patch-packs\latest-primary-live-patch-pack.md"
$LocalEvaluationRoot = Join-Path $ProjectRoot "workers\local-evaluations"
$OperatingModelPath = Join-Path $ProjectRoot "OPERATING_MODEL_V1.md"
$CatalogPath = Join-Path $ProjectRoot "workers\worker-catalog.v1.json"
$NorthbridgeDreamStatePath = Join-Path $ProjectRoot "runtime\state\northbridge-dream.state.json"
$NorthbridgeDreamLatestPath = Join-Path $ProjectRoot "runtime\dream\latest.md"
$ScheduledJobsStatePath = Join-Path $ProjectRoot "runtime\state\scheduled-jobs.state.json"
$LocalLlmStatePath = Join-Path $ProjectRoot "runtime\state\local-llm-runtime.state.json"

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

function Get-WorkerDisplayName {
  param(
    [Parameter(Mandatory = $true)]
    [string]$WorkerKey
  )

  if (-not $Catalog) {
    return $WorkerKey
  }

  $Definition = $Catalog.workers.$WorkerKey
  if (-not $Definition) {
    return $WorkerKey
  }

  $CharacterName = [string]$Definition.character_name
  $WorkerName = [string]$Definition.worker_name
  if ($CharacterName) {
    return ("{0} ({1})" -f $CharacterName, $WorkerKey)
  }
  if ($WorkerName) {
    return ("{0} ({1})" -f $WorkerName, $WorkerKey)
  }
  return $WorkerKey
}

$Catalog = $null
if (Test-Path $CatalogPath) {
  $Catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Json
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

$NorthbridgeDreamState = $null
if (Test-Path $NorthbridgeDreamStatePath) {
  $NorthbridgeDreamState = Get-Content $NorthbridgeDreamStatePath -Raw | ConvertFrom-Json
}

$ScheduledJobsState = $null
if (Test-Path $ScheduledJobsStatePath) {
  $ScheduledJobsState = Get-Content $ScheduledJobsStatePath -Raw | ConvertFrom-Json
}

$LocalLlmState = $null
if (Test-Path $LocalLlmStatePath) {
  $LocalLlmState = Get-Content $LocalLlmStatePath -Raw | ConvertFrom-Json
}

$Timestamp = Get-Date
$Stamp = $Timestamp.ToString("yyyyMMdd-HHmmss")
$MessagePath = Join-Path $InboxRoot ("{0}-northbridge-president.md" -f $Stamp)

$LastWorkerKey = if ($WorkerLabState) { [string]$WorkerLabState.last_worker_key } else { "unknown" }
$LastWorkerDisplay = if ($LastWorkerKey -ne "unknown") { Get-WorkerDisplayName -WorkerKey $LastWorkerKey } else { "unknown" }
$PrototypeCount = if ($Heartbeat) { [int]$Heartbeat.prototype_count } else { 0 }
$EvaluationCount = if ($Heartbeat) { [int]$Heartbeat.evaluation_count } else { 0 }
$ReviewCount = if ($Heartbeat) { [int]$Heartbeat.promotion_review_count } else { 0 }
$LabPlanCount = if ($Heartbeat) { [int]$Heartbeat.worker_lab_plan_count } else { 0 }
$LocalEvaluationRunCount = if ($Heartbeat -and $null -ne $Heartbeat.local_evaluation_run_count) { [int]$Heartbeat.local_evaluation_run_count } else { 0 }
$PatchReviewCount = if ($Heartbeat) { [int]$Heartbeat.patch_approval_request_count } else { 0 }
$DecisionBriefCount = if ($Heartbeat) { [int]$Heartbeat.patch_batch_decision_brief_count } else { 0 }
$ApprovedParallelSlots = if ($Heartbeat -and $null -ne $Heartbeat.approved_parallel_worker_slots) { [int]$Heartbeat.approved_parallel_worker_slots } else { 0 }
$EffectiveWorkerLanes = if ($Heartbeat -and $null -ne $Heartbeat.current_effective_worker_lanes) { [int]$Heartbeat.current_effective_worker_lanes } else { 0 }
$SupervisorCycle = if ($SupervisorStatus) { [int]$SupervisorStatus.cycle_count } else { 0 }
$SupervisorEnd = if ($SupervisorStatus) { [string]$SupervisorStatus.end_at } else { "" }
$PatchBoardRelativePath = if (Test-Path $PatchBoardPath) { $PatchBoardPath.Replace($ProjectRoot + "\", "") } else { "not_available" }
$DecisionBriefRelativePath = if (Test-Path $DecisionBriefPath) { $DecisionBriefPath.Replace($ProjectRoot + "\", "") } else { "not_available" }
$LivePatchReadinessRelativePath = if (Test-Path $LivePatchReadinessPath) { $LivePatchReadinessPath.Replace($ProjectRoot + "\", "") } else { "not_available" }
$LivePatchPackRelativePath = if (Test-Path $LivePatchPackPath) { $LivePatchPackPath.Replace($ProjectRoot + "\", "") } else { "not_available" }
$OperatingModelRelativePath = if (Test-Path $OperatingModelPath) { $OperatingModelPath.Replace($ProjectRoot + "\", "") } else { "not_available" }
$LatestLocalEvaluationRelativePath = "not_available"
$LastWorkerLocalEvaluationRoot = if ($LastWorkerKey -and $LastWorkerKey -ne "unknown") { Join-Path $LocalEvaluationRoot $LastWorkerKey } else { $null }
if ($LastWorkerLocalEvaluationRoot -and (Test-Path $LastWorkerLocalEvaluationRoot)) {
  $LatestLocalEvaluation = Get-ChildItem $LastWorkerLocalEvaluationRoot -Filter *-local-eval.md -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if ($LatestLocalEvaluation) {
    $LatestLocalEvaluationRelativePath = $LatestLocalEvaluation.FullName.Replace($ProjectRoot + "\", "")
  }
}
$PrimaryCandidate = "not_available"
$PrimaryCandidateDisplay = "not_available"
$PrimaryReadinessState = "not_available"
$NorthbridgeDreamReportRelativePath = if (Test-Path $NorthbridgeDreamLatestPath) { $NorthbridgeDreamLatestPath.Replace($ProjectRoot + "\", "") } else { "not_available" }
$NorthbridgeDreamLastStatus = if ($NorthbridgeDreamState) { [string]$NorthbridgeDreamState.last_status } else { "not_available" }
$NorthbridgeDreamLastCompletedAt = if ($NorthbridgeDreamState) { [string]$NorthbridgeDreamState.last_completed_at } else { "not_available" }
$ScheduledDreamStatus = if ($ScheduledJobsState -and $ScheduledJobsState.jobs -and $ScheduledJobsState.jobs.northbridge_dream) { [string]$ScheduledJobsState.jobs.northbridge_dream.last_status } else { "not_available" }
$LocalLlmStatus = if ($LocalLlmState) { [string]$LocalLlmState.status } else { "not_available" }
$LocalLlmReachable = if ($LocalLlmState) { [string]([bool]$LocalLlmState.reachable).ToString().ToLower() } else { "false" }
$LocalLlmModelAvailable = if ($LocalLlmState) { [string]([bool]$LocalLlmState.model_available).ToString().ToLower() } else { "false" }
$LocalLlmBaseUrl = if ($LocalLlmState) { [string]$LocalLlmState.base_url } else { "not_available" }
$LocalLlmDefaultModel = if ($LocalLlmState) { [string]$LocalLlmState.default_model } else { "not_available" }
$LocalLlmDetail = if ($LocalLlmState) { [string]$LocalLlmState.detail } else { "not_available" }
$LocalLlmRecoveryAttempted = if ($LocalLlmState) { [string]([bool]$LocalLlmState.recovery_attempted).ToString().ToLower() } else { "false" }
$LocalLlmRecoverySucceeded = if ($LocalLlmState) { [string]([bool]$LocalLlmState.recovery_succeeded).ToString().ToLower() } else { "false" }
$LocalLlmRecoveryCompletedAt = if ($LocalLlmState) { [string]$LocalLlmState.recovery_completed_at } else { "not_available" }
$LocalLlmRecoveryDetail = if ($LocalLlmState) { [string]$LocalLlmState.recovery_detail } else { "not_available" }
if (Test-Path $DecisionBriefPath) {
  $DecisionBriefText = Get-Content $DecisionBriefPath -Raw
  if ($DecisionBriefText -match '(?m)^- primary_first_live_patch_candidate:\s*(.+)$') {
    $PrimaryCandidate = $matches[1].Trim()
  }
  if ($DecisionBriefText -match '(?m)^- primary_first_live_patch_candidate_display:\s*(.+)$') {
    $PrimaryCandidateDisplay = $matches[1].Trim()
  } elseif ($PrimaryCandidate -ne "not_available") {
    $PrimaryCandidateDisplay = Get-WorkerDisplayName -WorkerKey $PrimaryCandidate
  }
}
if (Test-Path $LivePatchReadinessPath) {
  $ReadinessText = Get-Content $LivePatchReadinessPath -Raw
  if ($ReadinessText -match '(?m)^- overall_state:\s*(.+)$') {
    $PrimaryReadinessState = $matches[1].Trim()
  }
}

$Message = @"
# Northbridge President Inbox

## Message Meta

- created_at: {0}
- sender: worker continuity bot
- target: Northbridge Systems president

## Cycle Summary

- supervisor_cycle_count: {1}
- latest_worker_lab_target: {2}
- latest_worker_lab_target_key: {3}
- prototype_count: {4}
- evaluation_count: {5}
- promotion_review_count: {6}
- worker_lab_plan_count: {7}
- local_evaluation_run_count: {8}
- patch_approval_request_count: {9}
- patch_batch_decision_brief_count: {10}
- approved_parallel_worker_slots: {11}
- current_effective_worker_lanes: {12}

## Meaning

The unattended loop is active and has prepared the latest worker iteration focus for `{2}`.
Local worker evaluation evidence now exists and should be checked before trusting prompt-refinement docs.

## Recommended Executive Read

- inspect the newest worker-lab note for `{2}`
- inspect the latest local evaluation report for `{2}` before trusting a prompt patch recommendation
- decide whether to keep the current prompt or draft a revised candidate
- inspect the latest patch review board if prompt approval work is pending
- inspect the latest batch decision brief if you want the shortest approval path
- inspect the operating model if company mission or worker identity feels blurry
- if the loop looks idle, verify that a new worker-lab artifact appeared this cycle

## Review Board

- latest_patch_review_board: `{13}`

## Batch Decision Brief

- latest_patch_batch_decision_brief: `{14}`
- primary_first_live_patch_candidate: `{15}`
- primary_first_live_patch_candidate_key: `{16}`

## Local LLM Evidence

- latest_local_evaluation_report: `{17}`
- local_llm_status: `{18}`
- local_llm_reachable: `{19}`
- local_llm_model_available: `{20}`
- local_llm_base_url: `{21}`
- local_llm_default_model: `{22}`
- local_llm_detail: `{23}`
- local_llm_recovery_attempted: `{24}`
- local_llm_recovery_succeeded: `{25}`
- local_llm_recovery_completed_at: `{26}`
- local_llm_recovery_detail: `{27}`

## Operating Model

- sponsor_facing_operating_model: `{28}`

## Northbridge Dream

- latest_dream_report: `{29}`
- latest_dream_status: `{30}`
- latest_dream_completed_at: `{31}`
- scheduled_job_status: `{32}`

## First Live Patch Pack

- latest_primary_live_patch_pack: `{33}`
- latest_primary_live_patch_readiness: `{34}`
- primary_live_patch_state: `{35}`

## Supervisor Window

- expected_end_at: {36}

"@ -f `
  $Timestamp.ToString("o"),
  $SupervisorCycle,
  $LastWorkerDisplay,
  $LastWorkerKey,
  $PrototypeCount,
  $EvaluationCount,
  $ReviewCount,
  $LabPlanCount,
  $LocalEvaluationRunCount,
  $PatchReviewCount,
  $DecisionBriefCount,
  $ApprovedParallelSlots,
  $EffectiveWorkerLanes,
  $PatchBoardRelativePath,
  $DecisionBriefRelativePath,
  $PrimaryCandidateDisplay,
  $PrimaryCandidate,
  $LatestLocalEvaluationRelativePath,
  $LocalLlmStatus,
  $LocalLlmReachable,
  $LocalLlmModelAvailable,
  $LocalLlmBaseUrl,
  $LocalLlmDefaultModel,
  $LocalLlmDetail,
  $LocalLlmRecoveryAttempted,
  $LocalLlmRecoverySucceeded,
  $LocalLlmRecoveryCompletedAt,
  $LocalLlmRecoveryDetail,
  $OperatingModelRelativePath,
  $NorthbridgeDreamReportRelativePath,
  $NorthbridgeDreamLastStatus,
  $NorthbridgeDreamLastCompletedAt,
  $ScheduledDreamStatus,
  $LivePatchPackRelativePath,
  $LivePatchReadinessRelativePath,
  $PrimaryReadinessState,
  $SupervisorEnd

Write-Utf8NoBomFile -Path $MessagePath -Content ($Message.TrimStart() + "`n")
Write-Output "created president inbox message"
