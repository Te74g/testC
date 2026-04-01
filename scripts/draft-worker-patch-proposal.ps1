param(
  [string]$WorkerKey,
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$LabStatePath = Join-Path $ProjectRoot "runtime\state\worker-lab.state.json"
$PatchRoot = Join-Path $ProjectRoot "workers\patch-proposals"

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

if (-not $WorkerKey) {
  if (-not (Test-Path $LabStatePath)) {
    throw "worker lab state not found at $LabStatePath"
  }

  $LabState = Get-Content $LabStatePath -Raw | ConvertFrom-Json
  $WorkerKey = [string]$LabState.last_worker_key
  if (-not $WorkerKey) {
    throw "worker lab state is missing last_worker_key"
  }
}

$TrainingDir = Join-Path $ProjectRoot ("workers\training\{0}" -f $WorkerKey)
$LatestBrief = Get-ChildItem $TrainingDir -Filter *-training-brief.md -File -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $LatestBrief) {
  throw "no training brief found for $WorkerKey"
}

$Timestamp = Get-Date
$Stamp = $Timestamp.ToString("yyyyMMdd-HHmmss")
$WorkerPatchRoot = Join-Path $PatchRoot $WorkerKey
$ProposalPath = Join-Path $WorkerPatchRoot ("{0}-prompt-patch-proposal.md" -f $Stamp)

if ((Test-Path $ProposalPath) -and -not $Force) {
  Write-Output "skip existing patch proposal: $WorkerKey"
  return
}

$BriefText = Get-Content $LatestBrief.FullName -Raw
$PromptRelativePath = "workers/prototypes/{0}/prompt.md" -f $WorkerKey

$Theme = ""
$Hypothesis = ""
$Reinforcements = @()
$CurrentSection = ""

foreach ($Line in ($BriefText -split "`r?`n")) {
  if ($Line -match '^- theme:\s*(.+)$') {
    $Theme = $matches[1]
    continue
  }
  if ($Line -match '^- hypothesis:\s*(.+)$') {
    $Hypothesis = $matches[1]
    continue
  }
  if ($Line -match '^##\s+What To Reinforce') {
    $CurrentSection = "reinforce"
    continue
  }
  if ($Line -match '^##\s+') {
    $CurrentSection = ""
    continue
  }
  if ($CurrentSection -eq "reinforce" -and $Line -match '^- ') {
    $Reinforcements += ($Line -replace '^- ', '')
  }
}

if (-not $Theme) {
  $Theme = "focused prompt refinement"
}
if (-not $Hypothesis) {
  $Hypothesis = "A narrow prompt patch should improve worker behavior without changing authority."
}
if ($Reinforcements.Count -eq 0) {
  $Reinforcements = @("tighten role-specific behavior")
}

$InsertionBlock = @(
  "For the next evaluation pass, apply this training focus:"
  ("- theme: {0}" -f $Theme)
) + (@($Reinforcements) | ForEach-Object { "- $_" }) + @(
  "Keep the original authority boundary unchanged."
)

$Proposal = @"
# Prompt Patch Proposal: {0}

## Proposal Meta

- generated_at: {1}
- worker_key: {2}
- target_prompt: `{3}`
- based_on_training_brief: `{4}`

## Intent

- theme: {5}
- hypothesis: {6}

## Proposed Edit Strategy

Insert the following block immediately before the existing `At the end of each task, report:` section in the live prompt prototype.

## Proposed Insertion

~~~
{7}
~~~

## Why This Stays Safe

- it does not expand tool access
- it does not change escalation authority
- it is reversible
- it is narrow enough to test in the next evaluation pass

## Decision

- status: pending_review
- approved_for_live_patch: no
- notes:

"@ -f `
  $WorkerKey,
  $Timestamp.ToString("o"),
  $WorkerKey,
  $PromptRelativePath,
  ($LatestBrief.FullName.Replace($ProjectRoot + "\", "")),
  $Theme,
  $Hypothesis,
  ($InsertionBlock -join "`n")

Write-Utf8NoBomFile -Path $ProposalPath -Content ($Proposal.TrimStart() + "`n")
Write-Output "created worker patch proposal: $WorkerKey"
