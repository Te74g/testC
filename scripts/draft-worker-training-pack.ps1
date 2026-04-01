param(
  [string]$WorkerKey,
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$LabStatePath = Join-Path $ProjectRoot "runtime\state\worker-lab.state.json"
$TrainingRoot = Join-Path $ProjectRoot "workers\training"

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

$LabDir = Join-Path $ProjectRoot ("workers\lab\{0}" -f $WorkerKey)
$LatestLabPlan = Get-ChildItem $LabDir -Filter *-iteration-plan.md -File -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $LatestLabPlan) {
  throw "no worker lab plan found for $WorkerKey"
}

$PromptPath = Join-Path $ProjectRoot ("workers\prototypes\{0}\prompt.md" -f $WorkerKey)
$EvaluationPath = Join-Path $ProjectRoot ("workers\evaluations\{0}\evaluation-bundle.md" -f $WorkerKey)
$ReviewPath = Join-Path $ProjectRoot ("workers\reviews\{0}\promotion-review.md" -f $WorkerKey)

if (-not (Test-Path $PromptPath)) {
  throw "worker prompt not found for $WorkerKey"
}

$Timestamp = Get-Date
$Stamp = $Timestamp.ToString("yyyyMMdd-HHmmss")
$WorkerTrainingRoot = Join-Path $TrainingRoot $WorkerKey
$BriefPath = Join-Path $WorkerTrainingRoot ("{0}-training-brief.md" -f $Stamp)
$CandidatePath = Join-Path $WorkerTrainingRoot ("{0}-prompt-revision-candidate.md" -f $Stamp)

if (((Test-Path $BriefPath) -or (Test-Path $CandidatePath)) -and -not $Force) {
  Write-Output "skip existing training pack: $WorkerKey"
  return
}

$PromptText = Get-Content $PromptPath -Raw
$LabText = Get-Content $LatestLabPlan.FullName -Raw

$Theme = ""
$Hypothesis = ""
$HypothesisLines = New-Object System.Collections.Generic.List[string]
$Adjustments = @()
$PassSignals = @()
$CurrentSection = ""

foreach ($Line in ($LabText -split "`r?`n")) {
  if ($Line -match '^- theme:\s*(.+)$') {
    $Theme = $matches[1]
    continue
  }

  if ($Line -match '^##\s+Hypothesis') {
    $CurrentSection = "hypothesis"
    continue
  }
  if ($Line -match '^##\s+Prompt Adjustments To Test') {
    $CurrentSection = "adjustments"
    continue
  }
  if ($Line -match '^##\s+Pass Signals') {
    $CurrentSection = "signals"
    continue
  }
  if ($Line -match '^##\s+') {
    $CurrentSection = ""
    continue
  }

  if (-not $Line.Trim()) {
    continue
  }

  switch ($CurrentSection) {
    "hypothesis" {
      $HypothesisLines.Add($Line.Trim())
      continue
    }
    "adjustments" {
      if ($Line -match '^- ') {
        $Adjustments += ($Line -replace '^- ', '')
      }
      continue
    }
    "signals" {
      if ($Line -match '^- ') {
        $PassSignals += ($Line -replace '^- ', '')
      }
      continue
    }
  }
}

if (-not $Theme) {
  $Theme = "focused worker refinement"
}
if ($HypothesisLines.Count -gt 0) {
  $Hypothesis = ($HypothesisLines -join " ")
}
if (-not $Hypothesis) {
  $Hypothesis = "A narrower, more explicit prompt should improve role fidelity."
}

$Brief = @"
# Worker Training Brief: {0}

## Training Meta

- generated_at: {1}
- worker_key: {2}
- source_lab_plan: `{3}`

## Training Focus

- theme: {4}
- hypothesis: {5}

## Baseline References

- current_prompt: `{6}`
- evaluation_bundle: `{7}`
- promotion_review: `{8}`

## What To Reinforce

{9}

## What To Watch In Evaluation

{10}

## Coach Notes

- do not expand authority
- do not erase the worker's original role identity
- prefer a narrow revision candidate over a full rewrite
- treat this as a reversible draft, not a promotion decision

"@ -f `
  $WorkerKey,
  $Timestamp.ToString("o"),
  $WorkerKey,
  ($LatestLabPlan.FullName.Replace($ProjectRoot + "\", "")),
  $Theme,
  $Hypothesis,
  ($PromptPath.Replace($ProjectRoot + "\", "")),
  ($EvaluationPath.Replace($ProjectRoot + "\", "")),
  ($ReviewPath.Replace($ProjectRoot + "\", "")),
  ((@($Adjustments) | ForEach-Object { "- $_" }) -join "`n"),
  ((@($PassSignals) | ForEach-Object { "- $_" }) -join "`n")

$Candidate = @"
# Prompt Revision Candidate: {0}

## Revision Meta

- generated_at: {1}
- based_on_prompt: `{2}`
- based_on_lab_plan: `{3}`

## Revision Intent

- theme: {4}
- hypothesis: {5}

## Candidate Prompt

```
{6}

Current training focus:
- {7}

For the next evaluation pass, you must additionally:
{8}

When responding, keep your original authority boundary unchanged.
Do not expand your tool access or claim executive authority.
```

## Review Checklist

- does this keep the original worker identity intact?
- does this strengthen the current training theme?
- is the added instruction narrow enough to test cleanly?

"@ -f `
  $WorkerKey,
  $Timestamp.ToString("o"),
  ($PromptPath.Replace($ProjectRoot + "\", "")),
  ($LatestLabPlan.FullName.Replace($ProjectRoot + "\", "")),
  $Theme,
  $Hypothesis,
  ($PromptText.Trim()),
  $Theme,
  ((@($Adjustments) | ForEach-Object { "- $_" }) -join "`n")

Write-Utf8NoBomFile -Path $BriefPath -Content ($Brief.TrimStart() + "`n")
Write-Utf8NoBomFile -Path $CandidatePath -Content ($Candidate.TrimStart() + "`n")

Write-Output "created worker training pack: $WorkerKey"
