param(
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DecisionBriefPath = Join-Path $ProjectRoot "workers\decision-briefs\latest-worker-patch-decision-brief.md"
$CatalogPath = Join-Path $ProjectRoot "workers\worker-catalog.v1.json"
$PatchRoot = Join-Path $ProjectRoot "workers\patch-proposals"
$PreviewRoot = Join-Path $ProjectRoot "workers\prompt-previews"
$ApprovalRoot = Join-Path $ProjectRoot "workers\approval-requests"
$ReviewRoot = Join-Path $ProjectRoot "workers\reviews"
$PackRoot = Join-Path $ProjectRoot "workers\live-patch-packs"
$ReadinessPath = Join-Path $ProjectRoot "workers\live-patch-readiness\latest-primary-live-patch-readiness.md"
$LatestPackPath = Join-Path $PackRoot "latest-primary-live-patch-pack.md"
$HistoryPackPath = Join-Path $PackRoot ("{0}-primary-live-patch-pack.md" -f (Get-Date).ToString("yyyyMMdd-HHmmss"))

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

if (-not (Test-Path $DecisionBriefPath)) {
  throw "decision brief not found: $DecisionBriefPath"
}

$DecisionBriefText = Get-Content $DecisionBriefPath -Raw
if (-not ($DecisionBriefText -match '(?m)^- primary_first_live_patch_candidate:\s*(.+)$')) {
  throw "primary candidate not found in decision brief"
}
$WorkerKey = $matches[1].Trim()

$Catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Json
$Definition = $Catalog.workers.$WorkerKey
if (-not $Definition) {
  throw "worker definition not found for $WorkerKey"
}

$CharacterName = [string]$Definition.character_name
$WorkerName = [string]$Definition.worker_name
$DisplayName = if ($CharacterName) { "{0} ({1})" -f $CharacterName, $WorkerKey } else { $WorkerKey }

$ProposalPath = Get-LatestFileRelative -Root $PatchRoot -WorkerKey $WorkerKey -Filter "*-prompt-patch-proposal.md"
$PreviewPath = Get-LatestFileRelative -Root $PreviewRoot -WorkerKey $WorkerKey -Filter "*-prompt-preview.md"
$ApprovalPath = Get-LatestFileRelative -Root $ApprovalRoot -WorkerKey $WorkerKey -Filter "*-patch-approval-request.md"
$PromotionPath = Get-LatestFileRelative -Root $ReviewRoot -WorkerKey $WorkerKey -Filter "promotion-review.md"
$TargetPromptPath = "workers\prototypes\{0}\prompt.md" -f $WorkerKey
$ReadinessRelativePath = if (Test-Path $ReadinessPath) { $ReadinessPath.Replace($ProjectRoot + "\", "") } else { "not_available" }
$ReadinessState = "not_available"
if (Test-Path $ReadinessPath) {
  $ReadinessText = Get-Content $ReadinessPath -Raw
  if ($ReadinessText -match '(?m)^- overall_state:\s*(.+)$') {
    $ReadinessState = $matches[1].Trim()
  }
}

$Pack = @'
# Primary Live Patch Pack

## Pack Meta

- generated_at: {0}
- worker_key: {1}
- display_name: {2}
- character_name: {3}
- role_name: {4}

## Why This Worker

The latest batch decision brief names `{2}` as the current primary first-live-patch candidate.

## Review Set

- proposal: `{5}`
- preview: `{6}`
- approval_request: `{7}`
- promotion_review: `{8}`
- target_prompt: `{9}`
- readiness_report: `{10}`
- readiness_state: {11}

## Sponsor Commands

- approve proposal:
  `powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey {1} -Decision approve`
- refresh readiness:
  `powershell -ExecutionPolicy Bypass -File .\scripts\render-primary-live-patch-readiness.ps1`
- apply approved live patch:
  `powershell -ExecutionPolicy Bypass -File .\scripts\apply-primary-approved-live-patch.ps1`

## Fail-Closed Notes

- the apply helper resolves the primary candidate from the latest decision brief
- the apply helper still fails if the proposal is not explicitly approved
- prompt history and an apply log are written during live apply

## Short Checklist

1. review proposal and preview
2. inspect the readiness report
3. confirm the approval request still looks right
4. approve the proposal explicitly
5. run the primary approved live patch helper
6. inspect prompt history and apply log

'@ -f `
  (Get-Date).ToString("o"),
  $WorkerKey,
  $DisplayName,
  $CharacterName,
  $WorkerName,
  $ProposalPath,
  $PreviewPath,
  $ApprovalPath,
  $PromotionPath,
  $TargetPromptPath,
  $ReadinessRelativePath,
  $ReadinessState

Write-Utf8NoBomFile -Path $LatestPackPath -Content ($Pack.TrimStart() + "`n")
Write-Utf8NoBomFile -Path $HistoryPackPath -Content ($Pack.TrimStart() + "`n")
Write-Output "rendered primary live patch pack"
