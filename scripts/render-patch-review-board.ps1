param(
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PatchRoot = Join-Path $ProjectRoot "workers\patch-proposals"
$PreviewRoot = Join-Path $ProjectRoot "workers\prompt-previews"
$ApprovalRoot = Join-Path $ProjectRoot "workers\approval-requests"
$BoardRoot = Join-Path $ProjectRoot "workers\review-board"
$CatalogPath = Join-Path $ProjectRoot "workers\worker-catalog.v1.json"
$LatestBoardPath = Join-Path $BoardRoot "latest-patch-review-board.md"
$HistoryBoardPath = Join-Path $BoardRoot ("{0}-patch-review-board.md" -f (Get-Date).ToString("yyyyMMdd-HHmmss"))

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

$Catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Json

$LatestProposals = Get-ChildItem $PatchRoot -Recurse -Filter *-prompt-patch-proposal.md -File -ErrorAction SilentlyContinue |
  Group-Object DirectoryName |
  ForEach-Object {
    $_.Group | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  } |
  Sort-Object FullName

$Rows = New-Object System.Collections.Generic.List[string]
$PendingCount = 0

foreach ($ProposalFile in $LatestProposals) {
  $Text = Get-Content $ProposalFile.FullName -Raw
  if (-not ($Text -match '(?m)^- worker_key:\s*(.+)$')) { continue }
  $WorkerKey = $matches[1].Trim()

  $Status = "unknown"
  if ($Text -match '(?m)^- status:\s*(.+)$') {
    $Status = $matches[1].Trim()
  }

  $Approved = "unknown"
  if ($Text -match '(?m)^- approved_for_live_patch:\s*(.+)$') {
    $Approved = $matches[1].Trim()
  }

  $Theme = ""
  if ($Text -match '(?m)^- theme:\s*(.+)$') {
    $Theme = $matches[1].Trim()
  }

  $Identity = Get-WorkerIdentity -WorkerKey $WorkerKey

  if ($Status -eq "pending_review") {
    $PendingCount += 1
  }

  $PreviewPath = Get-LatestFileRelative -Root $PreviewRoot -WorkerKey $WorkerKey -Filter "*-prompt-preview.md"
  $ApprovalPath = Get-LatestFileRelative -Root $ApprovalRoot -WorkerKey $WorkerKey -Filter "*-patch-approval-request.md"

  $SuggestedCommand = switch ($Status) {
    "pending_review" { "powershell -ExecutionPolicy Bypass -File .\\scripts\\set-worker-patch-proposal-decision.ps1 -WorkerKey $WorkerKey -Decision approve|reject|defer" }
    "approved" { "powershell -ExecutionPolicy Bypass -File .\\scripts\\apply-approved-worker-patch.ps1 -WorkerKey $WorkerKey" }
    default { "review current artifacts before changing state" }
  }

  $Rows.Add((
@"
## {0}

- worker_key: {1}
- character_name: {2}
- role_name: {3}
- status: {4}
- approved_for_live_patch: {5}
- theme: {6}
- proposal: `{7}`
- preview: `{8}`
- approval_request: `{9}`
- suggested_next_command: `{10}`

"@ -f `
    $Identity.display_name,
    $WorkerKey,
    $Identity.character_name,
    $Identity.worker_name,
    $Status,
    $Approved,
    $Theme,
    ($ProposalFile.FullName.Replace($ProjectRoot + "\", "")),
    $PreviewPath,
    $ApprovalPath,
    $SuggestedCommand
  ))
}

$Board = @"
# Pending Worker Patch Review Board

## Board Meta

- generated_at: {0}
- pending_review_count: {1}
- worker_count_on_board: {2}

## Sponsor Guidance

- review pending workers first
- use the approval request file for rationale
- only apply live patches after explicit approval

{3}
"@ -f `
  (Get-Date).ToString("o"),
  $PendingCount,
  $Rows.Count,
  ($Rows -join "`n")

Write-Utf8NoBomFile -Path $LatestBoardPath -Content ($Board.TrimStart() + "`n")
Write-Utf8NoBomFile -Path $HistoryBoardPath -Content ($Board.TrimStart() + "`n")
Write-Output "rendered patch review board"
