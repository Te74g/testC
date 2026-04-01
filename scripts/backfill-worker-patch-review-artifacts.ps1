param(
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PatchRoot = Join-Path $ProjectRoot "workers\patch-proposals"
$PreviewRoot = Join-Path $ProjectRoot "workers\prompt-previews"
$ApprovalRoot = Join-Path $ProjectRoot "workers\approval-requests"

function Get-LatestFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [Parameter(Mandatory = $true)]
    [string]$WorkerKey,

    [Parameter(Mandatory = $true)]
    [string]$Filter
  )

  $Dir = Join-Path $Root $WorkerKey
  return Get-ChildItem $Dir -Filter $Filter -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
}

function Invoke-CheckedWorkerScript {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptName,

    [Parameter(Mandatory = $true)]
    [string]$WorkerKey
  )

  $Command = @(
    "-ExecutionPolicy", "Bypass",
    "-File", (Join-Path $PSScriptRoot $ScriptName),
    "-WorkerKey", $WorkerKey
  )

  if ($Force) {
    $Command += "-Force"
  }

  $Output = & powershell @Command
  if ($LASTEXITCODE -ne 0) {
    throw "$ScriptName failed for $WorkerKey with exit code $LASTEXITCODE"
  }

  if ($Output) {
    $Output
  }
}

$LatestProposals = Get-ChildItem $PatchRoot -Recurse -Filter *-prompt-patch-proposal.md -File -ErrorAction SilentlyContinue |
  Group-Object DirectoryName |
  ForEach-Object {
    $_.Group | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  } |
  Sort-Object FullName

$WorkersTouched = 0
$PreviewsCreated = 0
$ApprovalRequestsCreated = 0

foreach ($ProposalFile in $LatestProposals) {
  $Text = Get-Content $ProposalFile.FullName -Raw
  if (-not ($Text -match '(?m)^- worker_key:\s*(.+)$')) { continue }
  $WorkerKey = $matches[1].Trim()

  $Status = "unknown"
  if ($Text -match '(?m)^- status:\s*(.+)$') {
    $Status = $matches[1].Trim()
  }

  if ($Status -ne "pending_review") {
    continue
  }

  $WorkerTouched = $false
  $LatestPreview = Get-LatestFile -Root $PreviewRoot -WorkerKey $WorkerKey -Filter "*-prompt-preview.md"
  if (-not $LatestPreview -or $Force) {
    Invoke-CheckedWorkerScript -ScriptName "render-worker-prompt-preview.ps1" -WorkerKey $WorkerKey
    $PreviewsCreated += 1
    $WorkerTouched = $true
  }

  $LatestApprovalRequest = Get-LatestFile -Root $ApprovalRoot -WorkerKey $WorkerKey -Filter "*-patch-approval-request.md"
  if (-not $LatestApprovalRequest -or $Force) {
    Invoke-CheckedWorkerScript -ScriptName "draft-worker-patch-approval-request.ps1" -WorkerKey $WorkerKey
    $ApprovalRequestsCreated += 1
    $WorkerTouched = $true
  }

  if ($WorkerTouched) {
    $WorkersTouched += 1
  }
}

Write-Output ("backfilled patch review artifacts: workers={0} previews={1} approvals={2}" -f $WorkersTouched, $PreviewsCreated, $ApprovalRequestsCreated)
