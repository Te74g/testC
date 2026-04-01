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

if ($Proposal.approved_for_live_patch -ne "yes" -and -not $Force) {
  throw "proposal is not approved for live patch: $ResolvedProposalPath"
}

if (-not (Test-Path $Proposal.target_prompt_path)) {
  throw "target prompt not found: $($Proposal.target_prompt_path)"
}

$PromptText = Get-Content $Proposal.target_prompt_path -Raw
$Marker = "At the end of each task, report:"
$MarkerIndex = $PromptText.IndexOf($Marker)
if ($MarkerIndex -lt 0) {
  throw "target prompt is missing marker: $Marker"
}

$WorkerPrototypeDir = Split-Path -Parent $Proposal.target_prompt_path
$HistoryDir = Join-Path $WorkerPrototypeDir "history"
$Stamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
$ArchivedPromptPath = Join-Path $HistoryDir ("{0}-prompt.md" -f $Stamp)
$ApplyRecordPath = Join-Path $HistoryDir ("{0}-apply-log.md" -f $Stamp)

Write-Utf8NoBomFile -Path $ArchivedPromptPath -Content $PromptText

$PatchedPrompt = $PromptText.Insert($MarkerIndex, $Proposal.insertion_block + "`r`n`r`n")
Write-Utf8NoBomFile -Path $Proposal.target_prompt_path -Content $PatchedPrompt

$ApplyRecord = @"
# Worker Prompt Patch Application

- applied_at: {0}
- worker_key: {1}
- proposal_path: `{2}`
- archived_prompt: `{3}`
- target_prompt: `{4}`

"@ -f `
  (Get-Date).ToString("o"),
  $Proposal.worker_key,
  ($ResolvedProposalPath.Replace($ProjectRoot + "\", "")),
  ($ArchivedPromptPath.Replace($ProjectRoot + "\", "")),
  $Proposal.target_prompt_relative

Write-Utf8NoBomFile -Path $ApplyRecordPath -Content ($ApplyRecord.TrimStart() + "`n")
Write-Output "applied approved worker patch: $($Proposal.worker_key)"
