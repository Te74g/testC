param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$HeartbeatRoot = Join-Path $ProjectRoot "runtime\state\work-heartbeat"
$LatestPath = Join-Path $HeartbeatRoot "latest.json"
$HistoryPath = Join-Path $HeartbeatRoot "history.jsonl"
$RelayStatusPath = Join-Path $ProjectRoot "runtime\state\relay-bot.status.json"
$WorkersPrototypeRoot = Join-Path $ProjectRoot "workers\prototypes"
$WorkersEvaluationRoot = Join-Path $ProjectRoot "workers\evaluations"
$WorkersReviewRoot = Join-Path $ProjectRoot "workers\reviews"
$WorkersLabRoot = Join-Path $ProjectRoot "workers\lab"
$WorkersTrainingRoot = Join-Path $ProjectRoot "workers\training"
$WorkersPatchRoot = Join-Path $ProjectRoot "workers\patch-proposals"
$WorkersPreviewRoot = Join-Path $ProjectRoot "workers\prompt-previews"
$WorkersApprovalRoot = Join-Path $ProjectRoot "workers\approval-requests"
$WorkersLocalEvaluationRoot = Join-Path $ProjectRoot "workers\local-evaluations"
$WorkersReviewBoardRoot = Join-Path $ProjectRoot "workers\review-board"
$WorkersDecisionBriefRoot = Join-Path $ProjectRoot "workers\decision-briefs"
$PresidentInboxRoot = Join-Path $ProjectRoot "runtime\inbox\president"
$RuntimeSettingsPath = Join-Path $ProjectRoot "runtime\config\runtime-settings.v1.json"
$DreamReportRoot = Join-Path $ProjectRoot "runtime\dream\reports"
$DreamStatePath = Join-Path $ProjectRoot "runtime\state\northbridge-dream.state.json"
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

function Append-Utf8NoBomLine {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$Line
  )

  $Directory = Split-Path -Parent $Path
  if ($Directory) {
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }

  $Encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::AppendAllText($Path, $Line + "`n", $Encoding)
}

$RelayStatus = $null
if (Test-Path $RelayStatusPath) {
  $RelayStatus = Get-Content $RelayStatusPath -Raw | ConvertFrom-Json
}

$RuntimeSettings = $null
if (Test-Path $RuntimeSettingsPath) {
  $RuntimeSettings = Get-Content $RuntimeSettingsPath -Raw | ConvertFrom-Json
}

$DreamState = $null
if (Test-Path $DreamStatePath) {
  $DreamState = Get-Content $DreamStatePath -Raw | ConvertFrom-Json
}

$ScheduledJobsState = $null
if (Test-Path $ScheduledJobsStatePath) {
  $ScheduledJobsState = Get-Content $ScheduledJobsStatePath -Raw | ConvertFrom-Json
}

$LocalLlmState = $null
if (Test-Path $LocalLlmStatePath) {
  $LocalLlmState = Get-Content $LocalLlmStatePath -Raw | ConvertFrom-Json
}

$Record = [ordered]@{
  timestamp = (Get-Date).ToString("o")
  relay_status = $RelayStatus
  approved_parallel_worker_slots = if ($RuntimeSettings) { [int]$RuntimeSettings.approved_parallel_worker_slots } else { 10 }
  current_effective_worker_lanes = if ($RuntimeSettings) { [int]$RuntimeSettings.current_effective_worker_lanes } else { 1 }
  prototype_count = (Get-ChildItem $WorkersPrototypeRoot -Directory -ErrorAction SilentlyContinue | Measure-Object).Count
  evaluation_count = (Get-ChildItem $WorkersEvaluationRoot -Recurse -Filter evaluation-bundle.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  promotion_review_count = (Get-ChildItem $WorkersReviewRoot -Recurse -Filter promotion-review.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  worker_lab_plan_count = (Get-ChildItem $WorkersLabRoot -Recurse -Filter *-iteration-plan.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  training_brief_count = (Get-ChildItem $WorkersTrainingRoot -Recurse -Filter *-training-brief.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  prompt_revision_candidate_count = (Get-ChildItem $WorkersTrainingRoot -Recurse -Filter *-prompt-revision-candidate.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  local_evaluation_run_count = (Get-ChildItem $WorkersLocalEvaluationRoot -Recurse -Filter *-local-eval.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  prompt_patch_proposal_count = (Get-ChildItem $WorkersPatchRoot -Recurse -Filter *-prompt-patch-proposal.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  prompt_preview_count = (Get-ChildItem $WorkersPreviewRoot -Recurse -Filter *-prompt-preview.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  patch_approval_request_count = (Get-ChildItem $WorkersApprovalRoot -Recurse -Filter *-patch-approval-request.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  patch_review_board_count = (Get-ChildItem $WorkersReviewBoardRoot -Recurse -Filter *-patch-review-board.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  patch_batch_decision_brief_count = (Get-ChildItem $WorkersDecisionBriefRoot -Recurse -Filter *-worker-patch-decision-brief.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  northbridge_dream_report_count = (Get-ChildItem $DreamReportRoot -Filter *.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  northbridge_dream_last_status = if ($DreamState) { [string]$DreamState.last_status } else { "not_available" }
  northbridge_dream_last_completed_at = if ($DreamState) { [string]$DreamState.last_completed_at } else { "" }
  scheduled_jobs_last_run_at = if ($ScheduledJobsState) { [string]$ScheduledJobsState.last_scheduler_run_at } else { "" }
  scheduled_jobs_northbridge_dream_status = if ($ScheduledJobsState -and $ScheduledJobsState.jobs -and $ScheduledJobsState.jobs.northbridge_dream) { [string]$ScheduledJobsState.jobs.northbridge_dream.last_status } else { "not_available" }
  local_llm_status = if ($LocalLlmState) { [string]$LocalLlmState.status } else { "not_available" }
  local_llm_reachable = if ($LocalLlmState) { [bool]$LocalLlmState.reachable } else { $false }
  local_llm_model_available = if ($LocalLlmState) { [bool]$LocalLlmState.model_available } else { $false }
  local_llm_base_url = if ($LocalLlmState) { [string]$LocalLlmState.base_url } else { "" }
  local_llm_default_model = if ($LocalLlmState) { [string]$LocalLlmState.default_model } else { "" }
  local_llm_last_checked_at = if ($LocalLlmState) { [string]$LocalLlmState.checked_at } else { "" }
  local_llm_auto_recovery_enabled = if ($LocalLlmState) { [bool]$LocalLlmState.auto_recovery_enabled } else { $false }
  local_llm_recovery_attempted = if ($LocalLlmState) { [bool]$LocalLlmState.recovery_attempted } else { $false }
  local_llm_recovery_succeeded = if ($LocalLlmState) { [bool]$LocalLlmState.recovery_succeeded } else { $false }
  local_llm_recovery_completed_at = if ($LocalLlmState) { [string]$LocalLlmState.recovery_completed_at } else { "" }
  president_inbox_message_count = (Get-ChildItem $PresidentInboxRoot -Filter *.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
}

$Json = ($Record | ConvertTo-Json -Depth 10)
Write-Utf8NoBomFile -Path $LatestPath -Content ($Json + "`n")
Append-Utf8NoBomLine -Path $HistoryPath -Line ($Record | ConvertTo-Json -Depth 10 -Compress)

Write-Output "bot work heartbeat written"
