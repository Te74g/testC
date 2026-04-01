param(
  [string]$ProposalPath,
  [string]$WorkerKey,
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "resolve-worker-patch-proposal.ps1")

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

$ResolvedProposalPath = Resolve-WorkerPatchProposal -ProjectRoot $ProjectRoot -ProposalPath $ProposalPath -WorkerKey $WorkerKey
$Proposal = Read-WorkerPatchProposal -ProjectRoot $ProjectRoot -ResolvedProposalPath $ResolvedProposalPath

$PreviewDir = Join-Path $ProjectRoot ("workers\prompt-previews\{0}" -f $Proposal.worker_key)
$LatestPreview = Get-ChildItem $PreviewDir -Filter *-prompt-preview.md -File -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

$ProposalText = Get-Content $ResolvedProposalPath -Raw
$Theme = ""
$Hypothesis = ""

if ($ProposalText -match '(?m)^- theme:\s*(.+)$') {
  $Theme = $matches[1].Trim()
}
if ($ProposalText -match '(?m)^- hypothesis:\s*(.+)$') {
  $Hypothesis = $matches[1].Trim()
}

$ApprovalRoot = Join-Path $ProjectRoot ("workers\approval-requests\{0}" -f $Proposal.worker_key)
$Stamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
$RequestPath = Join-Path $ApprovalRoot ("{0}-patch-approval-request.md" -f $Stamp)

if ((Test-Path $RequestPath) -and -not $Force) {
  Write-Output "skip existing patch approval request: $($Proposal.worker_key)"
  return
}

$PreviewRelative = if ($LatestPreview) { $LatestPreview.FullName.Replace($ProjectRoot + "\", "") } else { "not_generated" }

$Request = @"
# Worker Patch Approval Request: {0}

## Request Meta

- generated_at: {1}
- worker_key: {2}
- proposal_path: `{3}`
- preview_path: `{4}`
- target_prompt: `{5}`

## Requested Decision

- current_status: pending_review
- requested_action: approve_or_reject

## Change Summary

- theme: {6}
- hypothesis: {7}

## Why This Is Still Safe

- the proposal does not add new tools
- the proposal does not change escalation authority
- a preview exists for review before live mutation
- live application is still blocked unless the proposal is explicitly approved

## Sponsor Command Hints

- approve:
  `powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey {2} -Decision approve`
- reject:
  `powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey {2} -Decision reject`
- defer:
  `powershell -ExecutionPolicy Bypass -File .\scripts\set-worker-patch-proposal-decision.ps1 -WorkerKey {2} -Decision defer`

## Notes

- decision:
- rationale:

"@ -f `
  $Proposal.worker_key,
  (Get-Date).ToString("o"),
  $Proposal.worker_key,
  ($ResolvedProposalPath.Replace($ProjectRoot + "\", "")),
  $PreviewRelative,
  $Proposal.target_prompt_relative,
  $Theme,
  $Hypothesis

Write-Utf8NoBomFile -Path $RequestPath -Content ($Request.TrimStart() + "`n")
Write-Output "created patch approval request: $($Proposal.worker_key)"
