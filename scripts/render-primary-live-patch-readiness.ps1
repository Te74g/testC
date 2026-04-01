param()

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DecisionBriefPath = Join-Path $ProjectRoot "workers\decision-briefs\latest-worker-patch-decision-brief.md"
$ReadinessRoot = Join-Path $ProjectRoot "workers\live-patch-readiness"
$LatestPath = Join-Path $ReadinessRoot "latest-primary-live-patch-readiness.md"
$HistoryPath = Join-Path $ReadinessRoot ("{0}-primary-live-patch-readiness.md" -f (Get-Date).ToString("yyyyMMdd-HHmmss"))

. (Join-Path $PSScriptRoot "get-live-patch-readiness.ps1")

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

$WorkerKey = Get-PrimaryWorkerKeyFromDecisionBrief -DecisionBriefPath $DecisionBriefPath
$Readiness = Get-LivePatchReadiness -ProjectRoot $ProjectRoot -WorkerKey $WorkerKey

$Report = @'
# Primary Live Patch Readiness

## Readiness Meta

- generated_at: {0}
- worker_key: {1}
- display_name: {2}
- overall_state: {3}
- blocking_reason: {4}

## Checks

- decision_brief: `{5}`
- proposal: `{6}`
- preview: `{7}`
- approval_request: `{8}`
- promotion_review: `{9}`
- target_prompt: `{10}`
- promotion_state: {11}
- approved_for_live_patch: {12}
- target_prompt_marker_present: {13}
- insertion_already_present: {14}

## Interpretation

- `ready_to_apply`: sponsor approval exists and apply may proceed
- `pending_sponsor_approval`: everything else is in place, but approval is still missing
- `blocked_missing_artifact`: missing or insufficient prerequisites
- `already_applied_or_duplicate_risk`: do not apply again without review

'@ -f `
  (Get-Date).ToString("o"),
  $Readiness.worker_key,
  $Readiness.display_name,
  $Readiness.overall_state,
  $(if ($Readiness.blocking_reason) { $Readiness.blocking_reason } else { "none" }),
  $Readiness.decision_brief_path,
  $Readiness.proposal_path,
  $Readiness.preview_path,
  $Readiness.approval_request_path,
  $Readiness.promotion_review_path,
  $Readiness.target_prompt_path,
  $Readiness.promotion_state,
  $Readiness.approval_flag,
  $Readiness.marker_present.ToString().ToLowerInvariant(),
  $Readiness.insertion_already_present.ToString().ToLowerInvariant()

Write-Utf8NoBomFile -Path $LatestPath -Content ($Report.TrimStart() + "`n")
Write-Utf8NoBomFile -Path $HistoryPath -Content ($Report.TrimStart() + "`n")
Write-Output "rendered primary live patch readiness"
