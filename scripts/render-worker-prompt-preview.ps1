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

if (-not (Test-Path $Proposal.target_prompt_path)) {
  throw "target prompt not found: $($Proposal.target_prompt_path)"
}

$PromptText = Get-Content $Proposal.target_prompt_path -Raw
$Marker = "At the end of each task, report:"
$MarkerIndex = $PromptText.IndexOf($Marker)
if ($MarkerIndex -lt 0) {
  throw "target prompt is missing marker: $Marker"
}

$InsertionText = $Proposal.insertion_block + "`r`n`r`n"
$PatchedPrompt = $PromptText.Insert($MarkerIndex, $InsertionText)

$PreviewRoot = Join-Path $ProjectRoot ("workers\prompt-previews\{0}" -f $Proposal.worker_key)
$Stamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
$PreviewPath = Join-Path $PreviewRoot ("{0}-prompt-preview.md" -f $Stamp)

if ((Test-Path $PreviewPath) -and -not $Force) {
  Write-Output "skip existing prompt preview: $($Proposal.worker_key)"
  return
}

$Preview = @"
# Worker Prompt Preview: {0}

## Preview Meta

- generated_at: {1}
- worker_key: {2}
- proposal_path: `{3}`
- target_prompt: `{4}`

## Preview

~~~
{5}
~~~

"@ -f `
  $Proposal.worker_key,
  (Get-Date).ToString("o"),
  $Proposal.worker_key,
  ($ResolvedProposalPath.Replace($ProjectRoot + "\", "")),
  $Proposal.target_prompt_relative,
  ($PatchedPrompt.Trim())

Write-Utf8NoBomFile -Path $PreviewPath -Content ($Preview.TrimStart() + "`n")
Write-Output "created worker prompt preview: $($Proposal.worker_key)"
