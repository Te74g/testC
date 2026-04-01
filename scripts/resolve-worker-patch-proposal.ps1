function Resolve-WorkerPatchProposal {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [string]$ProposalPath,
    [string]$WorkerKey
  )

  if ($ProposalPath) {
    $ResolvedProposalPath = if ([System.IO.Path]::IsPathRooted($ProposalPath)) {
      $ProposalPath
    } else {
      Join-Path $ProjectRoot $ProposalPath
    }

    if (-not (Test-Path $ResolvedProposalPath)) {
      throw "proposal path not found: $ResolvedProposalPath"
    }

    return $ResolvedProposalPath
  }

  if (-not $WorkerKey) {
    $LabStatePath = Join-Path $ProjectRoot "runtime\state\worker-lab.state.json"
    if (-not (Test-Path $LabStatePath)) {
      throw "worker lab state not found at $LabStatePath"
    }
    $LabState = Get-Content $LabStatePath -Raw | ConvertFrom-Json
    $WorkerKey = [string]$LabState.last_worker_key
  }

  if (-not $WorkerKey) {
    throw "worker key could not be resolved for patch proposal"
  }

  $PatchDir = Join-Path $ProjectRoot ("workers\patch-proposals\{0}" -f $WorkerKey)
  $LatestProposal = Get-ChildItem $PatchDir -Filter *-prompt-patch-proposal.md -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if (-not $LatestProposal) {
    throw "no patch proposal found for $WorkerKey"
  }

  return $LatestProposal.FullName
}

function Read-WorkerPatchProposal {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [Parameter(Mandatory = $true)]
    [string]$ResolvedProposalPath
  )

  $Text = Get-Content $ResolvedProposalPath -Raw

  if (-not ($Text -match '(?m)^- worker_key:\s*(.+)$')) {
    throw "worker_key not found in proposal: $ResolvedProposalPath"
  }
  $WorkerKey = $matches[1].Trim()

  if (-not ($Text -match '(?m)^- target_prompt:\s*(.+)$')) {
    throw "target_prompt not found in proposal: $ResolvedProposalPath"
  }
  $TargetPromptRelative = $matches[1].Trim()

  if (-not ($Text -match '(?m)^- approved_for_live_patch:\s*(.+)$')) {
    throw "approved_for_live_patch not found in proposal: $ResolvedProposalPath"
  }
  $ApprovedValue = $matches[1].Trim().ToLowerInvariant()

  $Insertion = $null
  if ($Text -match '(?ms)^~~~\r?\n(.*?)\r?\n~~~') {
    $Insertion = $matches[1].Trim()
  } elseif ($Text -match '(?ms)^`\r?\n(.*?)\r?\n`') {
    $Insertion = $matches[1].Trim()
  } else {
    throw "proposal insertion block not found in proposal: $ResolvedProposalPath"
  }

  $ResolvedTargetPromptPath = Join-Path $ProjectRoot ($TargetPromptRelative -replace '/', '\')

  return [pscustomobject]@{
    proposal_path = $ResolvedProposalPath
    worker_key = $WorkerKey
    approved_for_live_patch = $ApprovedValue
    target_prompt_relative = $TargetPromptRelative
    target_prompt_path = $ResolvedTargetPromptPath
    insertion_block = $Insertion
  }
}
