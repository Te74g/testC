param(
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PatchRoot = Join-Path $ProjectRoot "workers\patch-proposals"
$PreviewRoot = Join-Path $ProjectRoot "workers\prompt-previews"
$ApprovalRoot = Join-Path $ProjectRoot "workers\approval-requests"
$ReviewRoot = Join-Path $ProjectRoot "workers\reviews"
$DecisionRoot = Join-Path $ProjectRoot "workers\decision-briefs"
$CatalogPath = Join-Path $ProjectRoot "workers\worker-catalog.v1.json"
$LatestDecisionPath = Join-Path $DecisionRoot "latest-worker-patch-decision-brief.md"
$HistoryDecisionPath = Join-Path $DecisionRoot ("{0}-worker-patch-decision-brief.md" -f (Get-Date).ToString("yyyyMMdd-HHmmss"))

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

function Get-LatestFileRelative {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [Parameter(Mandatory = $true)]
    [string]$WorkerKey,

    [Parameter(Mandatory = $true)]
    [string]$Filter
  )

  $Dir = Join-Path $Root $WorkerKey
  $Latest = Get-ChildItem $Dir -Filter $Filter -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if (-not $Latest) {
    return "not_available"
  }

  return $Latest.FullName.Replace($ProjectRoot + "\", "")
}

function Get-PromotionSignal {
  param(
    [Parameter(Mandatory = $true)]
    [string]$WorkerKey
  )

  $ReviewPath = Join-Path $ReviewRoot (Join-Path $WorkerKey "promotion-review.md")
  if (-not (Test-Path $ReviewPath)) {
    return [pscustomobject]@{
      state = "not_reviewed"
      relative_path = "not_available"
    }
  }

  $Text = Get-Content $ReviewPath -Raw
  $State = "reviewed"
  if ($Text -match '(?m)^- decision:\s*\*\*promote\*\*') {
    $State = "promoted"
  } elseif ($Text -match '(?m)^- decision:\s*\*\*reject\*\*') {
    $State = "rejected"
  }

  return [pscustomobject]@{
    state = $State
    relative_path = $ReviewPath.Replace($ProjectRoot + "\", "")
  }
}

function Get-WorkerIdentity {
  param(
    [Parameter(Mandatory = $true)]
    [string]$WorkerKey
  )

  $Definition = $Catalog.workers.$WorkerKey
  if (-not $Definition) {
    return [pscustomobject]@{
      worker_name = $WorkerKey
      character_name = $WorkerKey
      display_name = $WorkerKey
    }
  }

  $WorkerName = [string]$Definition.worker_name
  $CharacterName = [string]$Definition.character_name
  if (-not $CharacterName) {
    $CharacterName = $WorkerName
  }

  return [pscustomobject]@{
    worker_name = $WorkerName
    character_name = $CharacterName
    display_name = ("{0} ({1})" -f $CharacterName, $WorkerKey)
  }
}

function Get-RecommendationRank {
  param(
    [Parameter(Mandatory = $true)]
    [string]$WorkerKey,

    [Parameter(Mandatory = $true)]
    [string]$Theme
  )

  $Base = switch ($WorkerKey) {
    "W-03-researcher" { 100 }
    "W-04-editor" { 90 }
    "W-01-builder" { 70 }
    "W-02-verifier" { 60 }
    "W-05-watcher" { 50 }
    default { 40 }
  }

  if ($Theme -match "aggressive") {
    $Base -= 15
  }

  return $Base
}

$Catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Json

$LatestProposals = Get-ChildItem $PatchRoot -Recurse -Filter *-prompt-patch-proposal.md -File -ErrorAction SilentlyContinue |
  Group-Object DirectoryName |
  ForEach-Object {
    $_.Group | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  } |
  Sort-Object FullName

$Rows = New-Object System.Collections.Generic.List[object]

foreach ($ProposalFile in $LatestProposals) {
  $Text = Get-Content $ProposalFile.FullName -Raw
  if (-not ($Text -match '(?m)^- worker_key:\s*(.+)$')) { continue }
  $WorkerKey = $matches[1].Trim()

  $Status = ""
  if ($Text -match '(?m)^- status:\s*(.+)$') {
    $Status = $matches[1].Trim()
  }
  if ($Status -ne "pending_review") {
    continue
  }

  $Theme = ""
  if ($Text -match '(?m)^- theme:\s*(.+)$') {
    $Theme = $matches[1].Trim()
  }

  $Hypothesis = ""
  if ($Text -match '(?m)^- hypothesis:\s*(.+)$') {
    $Hypothesis = $matches[1].Trim()
  }

  $PreviewPath = Get-LatestFileRelative -Root $PreviewRoot -WorkerKey $WorkerKey -Filter "*-prompt-preview.md"
  $ApprovalPath = Get-LatestFileRelative -Root $ApprovalRoot -WorkerKey $WorkerKey -Filter "*-patch-approval-request.md"
  $Promotion = Get-PromotionSignal -WorkerKey $WorkerKey
  $Identity = Get-WorkerIdentity -WorkerKey $WorkerKey

  $Recommendation = "defer"
  $Reason = "promotion evidence is not strong enough yet"
  if ($PreviewPath -ne "not_available" -and $ApprovalPath -ne "not_available" -and $Promotion.state -eq "promoted") {
    $Recommendation = "approve"
    $Reason = "complete artifact set plus promote decision"
  }

  $Rows.Add([pscustomobject]@{
      WorkerKey = $WorkerKey
      WorkerName = $Identity.worker_name
      CharacterName = $Identity.character_name
      DisplayName = $Identity.display_name
      Theme = $Theme
      Hypothesis = $Hypothesis
      ProposalPath = $ProposalFile.FullName.Replace($ProjectRoot + "\", "")
      PreviewPath = $PreviewPath
      ApprovalPath = $ApprovalPath
      PromotionState = $Promotion.state
      PromotionPath = $Promotion.relative_path
      Recommendation = $Recommendation
      Reason = $Reason
      Rank = Get-RecommendationRank -WorkerKey $WorkerKey -Theme $Theme
    })
}

$ApproveRows = $Rows | Where-Object { $_.Recommendation -eq "approve" } | Sort-Object @{ Expression = { $_.Rank }; Descending = $true }, WorkerKey
$DeferRows = $Rows | Where-Object { $_.Recommendation -eq "defer" } | Sort-Object WorkerKey
$PrimaryCandidate = if ($ApproveRows) { $ApproveRows[0].WorkerKey } else { "not_available" }
$PrimaryCandidateDisplay = if ($ApproveRows) { $ApproveRows[0].DisplayName } else { "not_available" }

$CombinedCommandLines = New-Object System.Collections.Generic.List[string]
foreach ($Row in $ApproveRows) {
  $CombinedCommandLines.Add(("powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey {0} -Decision approve" -f $Row.WorkerKey))
}
foreach ($Row in $DeferRows) {
  $CombinedCommandLines.Add(("powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey {0} -Decision defer" -f $Row.WorkerKey))
}
$CombinedCommandBlock = if ($CombinedCommandLines.Count -gt 0) {
  ($CombinedCommandLines -join "`r`n")
} else {
  "not_available"
}

$Sections = New-Object System.Collections.Generic.List[string]
foreach ($Row in ($Rows | Sort-Object @{ Expression = { if ($_.Recommendation -eq "approve") { 0 } else { 1 } } }, @{ Expression = { -$_.Rank } }, WorkerKey)) {
  $Sections.Add((
@"
## {0}

- worker_key: {1}
- character_name: {2}
- role_name: {3}
- recommendation: {4}
- reason: {5}
- theme: {6}
- hypothesis: {7}
- promotion_signal: {8}
- proposal: `{9}`
- preview: `{10}`
- approval_request: `{11}`
- promotion_review: `{12}`
- decision_command: `powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey {1} -Decision {4}`

"@ -f `
    $Row.DisplayName,
    $Row.WorkerKey,
    $Row.CharacterName,
    $Row.WorkerName,
    $Row.Recommendation,
    $Row.Reason,
    $Row.Theme,
    $Row.Hypothesis,
    $Row.PromotionState,
    $Row.ProposalPath,
    $Row.PreviewPath,
    $Row.ApprovalPath,
    $Row.PromotionPath
  ))
}

$DecisionBrief = @"
# Worker Patch Batch Decision Brief

## Decision Meta

- generated_at: {0}
- pending_worker_count: {1}
- recommended_approve_count: {2}
- recommended_defer_count: {3}
- primary_first_live_patch_candidate: {4}
- primary_first_live_patch_candidate_display: {5}

## Sponsor Guidance

- approve only workers with both complete artifacts and stronger promotion evidence
- use defer when the patch itself looks safe but readiness evidence is still thin
- if you want one first live patch, start with `{5}`

## Combined Command Draft

~~~
{6}
~~~

{7}
"@ -f `
  (Get-Date).ToString("o"),
  $Rows.Count,
  $ApproveRows.Count,
  $DeferRows.Count,
  $PrimaryCandidate,
  $PrimaryCandidateDisplay,
  $CombinedCommandBlock,
  ($Sections -join "`n")

Write-Utf8NoBomFile -Path $LatestDecisionPath -Content ($DecisionBrief.TrimStart() + "`n")
Write-Utf8NoBomFile -Path $HistoryDecisionPath -Content ($DecisionBrief.TrimStart() + "`n")
Write-Output "rendered worker patch batch decision brief"
