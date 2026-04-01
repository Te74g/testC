param(
  [string]$ProposalPath,
  [string]$WorkerKey,

  [Parameter(Mandatory = $true)]
  [ValidateSet("approve", "reject", "defer")]
  [string]$Decision,

  [string]$Note = ""
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
$ProposalText = Get-Content $ResolvedProposalPath -Raw

$StatusValue = switch ($Decision) {
  "approve" { "approved" }
  "reject" { "rejected" }
  "defer" { "deferred" }
}

$ApprovalValue = if ($Decision -eq "approve") { "yes" } else { "no" }

$UpdatedText = $ProposalText `
  -replace '(?m)^- status:\s*.+$', ("- status: {0}" -f $StatusValue) `
  -replace '(?m)^- approved_for_live_patch:\s*.+$', ("- approved_for_live_patch: {0}" -f $ApprovalValue)

if ($Note) {
  if ($UpdatedText -match '(?m)^- notes:\s*$') {
    $UpdatedText = $UpdatedText -replace '(?m)^- notes:\s*$', ("- notes: {0}" -f $Note)
  } elseif ($UpdatedText -match '(?m)^- notes:\s*.+$') {
    $UpdatedText = $UpdatedText -replace '(?m)^- notes:\s*.+$', ("- notes: {0}" -f $Note)
  }
}

Write-Utf8NoBomFile -Path $ResolvedProposalPath -Content $UpdatedText
Write-Output ("updated patch proposal decision: {0} -> {1}" -f $ResolvedProposalPath, $StatusValue)
