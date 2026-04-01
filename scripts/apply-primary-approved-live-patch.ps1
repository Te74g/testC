param()

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DecisionBriefPath = Join-Path $ProjectRoot "workers\decision-briefs\latest-worker-patch-decision-brief.md"
$ApplyScriptPath = Join-Path $PSScriptRoot "apply-approved-worker-patch.ps1"
. (Join-Path $PSScriptRoot "get-live-patch-readiness.ps1")

if (-not (Test-Path $DecisionBriefPath)) {
  throw "decision brief not found: $DecisionBriefPath"
}

$DecisionBriefText = Get-Content $DecisionBriefPath -Raw
if (-not ($DecisionBriefText -match '(?m)^- primary_first_live_patch_candidate:\s*(.+)$')) {
  throw "primary candidate not found in decision brief"
}

$WorkerKey = Get-PrimaryWorkerKeyFromDecisionBrief -DecisionBriefPath $DecisionBriefPath
$Readiness = Get-LivePatchReadiness -ProjectRoot $ProjectRoot -WorkerKey $WorkerKey

if ($Readiness.overall_state -ne "ready_to_apply") {
  throw ("primary candidate is not ready to apply: {0} ({1})" -f $Readiness.overall_state, $Readiness.blocking_reason)
}

$Output = & powershell -ExecutionPolicy Bypass -File $ApplyScriptPath -WorkerKey $WorkerKey
if ($LASTEXITCODE -ne 0) {
  throw "apply-approved-worker-patch failed for $WorkerKey with exit code $LASTEXITCODE"
}

if ($Output) {
  $Output
}
