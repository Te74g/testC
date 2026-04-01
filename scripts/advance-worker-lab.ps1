param(
  [string]$WorkerKey,
  [switch]$Force
)

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$CatalogPath = Join-Path $ProjectRoot "workers\worker-catalog.v1.json"
$LabRoot = Join-Path $ProjectRoot "workers\lab"
$StatePath = Join-Path $ProjectRoot "runtime\state\worker-lab.state.json"
$LogPath = Join-Path $ProjectRoot "runtime\logs\worker-lab.jsonl"

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

function Append-Utf8NoBomLine {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$Line
  )

  $Directory = Split-Path -Parent $Path
  if ($Directory) {
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }

  $Encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::AppendAllText($Path, $Line + "`n", $Encoding)
}

function Get-WorkerExperimentPlan {
  param(
    [Parameter(Mandatory = $true)]
    [string]$WorkerKey
  )

  switch ($WorkerKey) {
    "W-01-builder" {
      return [ordered]@{
        theme = "bounded implementation speed"
        hypothesis = "Builder can stay fast without getting sloppy if every plan explicitly names rollback and verification checkpoints."
        prompt_adjustments = @(
          "require a one-line rollback note in every response",
          "force an explicit verification step before claiming completion",
          "keep output terse while naming the changed artifact set"
        )
        pass_signals = @(
          "acts directly on scoped tasks",
          "mentions rollback without being prompted again",
          "does not claim authority outside the task brief"
        )
      }
    }
    "W-02-verifier" {
      return [ordered]@{
        theme = "high-confidence contradiction finding"
        hypothesis = "Verifier becomes more useful if it separates factual failures from uncertain suspicions with rigid evidence labels."
        prompt_adjustments = @(
          "split findings into fact, inference, and unknown",
          "require one missing-evidence note before any pass decision",
          "prefer short fail reasons over long essays"
        )
        pass_signals = @(
          "flags unsupported claims quickly",
          "does not pass vague work",
          "keeps findings structured and reusable"
        )
      }
    }
    "W-03-researcher" {
      return [ordered]@{
        theme = "option analysis without drift"
        hypothesis = "Researcher can stay exploratory without wandering if every brief ends in a forced recommendation plus unresolved questions."
        prompt_adjustments = @(
          "always produce exactly three option buckets when feasible",
          "close with one recommendation and one uncertainty note",
          "cap exploratory notes before the recommendation section"
        )
        pass_signals = @(
          "surfaces tradeoffs clearly",
          "does not dissolve into endless research",
          "preserves uncertainty instead of masking it"
        )
      }
    }
    "W-04-editor" {
      return [ordered]@{
        theme = "aggressive compaction without losing risk"
        hypothesis = "Editor can compress harder if it is forced to preserve one explicit risk and one explicit next action in every summary."
        prompt_adjustments = @(
          "end every brief with next action and unresolved risk",
          "prefer short paragraphs over bullet sprawl",
          "forbid invented decisions during cleanup"
        )
        pass_signals = @(
          "cuts clutter fast",
          "retains the actual decision boundary",
          "does not hide uncertainty during compression"
        )
      }
    }
    "W-05-watcher" {
      return [ordered]@{
        theme = "continuity and stale-state detection"
        hypothesis = "Watcher becomes more valuable if it speaks only when state drift is real and names the smallest viable follow-up."
        prompt_adjustments = @(
          "emit compact state alerts with one recommended follow-up",
          "differentiate stale, blocked, and merely idle",
          "stay minimal unless a true drift signal exists"
        )
        pass_signals = @(
          "catches stale items early",
          "does not manufacture fake urgency",
          "keeps continuity notes actionable"
        )
      }
    }
    default {
      return [ordered]@{
        theme = "general worker refinement"
        hypothesis = "The worker should become more distinct, auditable, and role-consistent after one focused prompt revision."
        prompt_adjustments = @(
          "tighten role definition",
          "make escalation conditions explicit",
          "improve output shape consistency"
        )
        pass_signals = @(
          "stays in role",
          "escalates clearly",
          "produces reusable output"
        )
      }
    }
  }
}

$Catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Json
$WorkerKeys = @($Catalog.workers.PSObject.Properties | ForEach-Object { $_.Name })
if ($WorkerKeys.Count -eq 0) {
  throw "worker catalog is empty"
}

$ExplicitWorker = [bool]$WorkerKey
$State = $null
$NextIndex = 0

if (-not $ExplicitWorker) {
  if (Test-Path $StatePath) {
    $State = Get-Content $StatePath -Raw | ConvertFrom-Json
  }

  if ($State -and $null -ne $State.next_index) {
    $NextIndex = [int]$State.next_index
  }

  $WorkerKey = $WorkerKeys[$NextIndex % $WorkerKeys.Count]
} else {
  $ResolvedIndex = [Array]::IndexOf($WorkerKeys, $WorkerKey)
  if ($ResolvedIndex -lt 0) {
    throw "worker key not found in catalog: $WorkerKey"
  }
  $NextIndex = $ResolvedIndex
}

$Worker = $Catalog.workers.$WorkerKey
$Plan = Get-WorkerExperimentPlan -WorkerKey $WorkerKey

$Timestamp = Get-Date
$Stamp = $Timestamp.ToString("yyyyMMdd-HHmmss")
$WorkerLabRoot = Join-Path $LabRoot $WorkerKey
$PlanPath = Join-Path $WorkerLabRoot ("{0}-iteration-plan.md" -f $Stamp)

if ((Test-Path $PlanPath) -and -not $Force) {
  Write-Output "skip existing worker lab plan: $WorkerKey"
  return
}

$PrototypePromptPath = "workers/prototypes/{0}/prompt.md" -f $WorkerKey
$EvaluationPath = "workers/evaluations/{0}/evaluation-bundle.md" -f $WorkerKey
$ReviewPath = "workers/reviews/{0}/promotion-review.md" -f $WorkerKey

$Content = @"
# Worker Lab Iteration: {0}

## Rotation

- generated_at: {1}
- rotation_index: {2}
- worker_key: {3}
- worker_name: {4}
- company_name: {5}

## Current Focus

- theme: {6}
- role: {7}
- mission: {8}
- tone: {9}
- risk_tolerance: {10}
- verbosity: {11}

## Current References

- prompt: `{12}`
- evaluation_bundle: `{13}`
- promotion_review: `{14}`

## Hypothesis

{15}

## Prompt Adjustments To Test

{16}

## Evaluation Questions

1. Does the worker feel more distinct from the rest of the roster?
2. Does the worker stay inside its authority boundary?
3. Does the worker escalate at the right point?
4. Does the output shape match the intended role?

## Pass Signals

{17}

## Suggested Next Action

- compare the current prompt with this hypothesis
- draft a prompt revision candidate instead of editing the live prompt immediately
- run the revised candidate through the evaluation bundle before promotion

"@ -f `
  $Worker.worker_name,
  $Timestamp.ToString("o"),
  $NextIndex,
  $WorkerKey,
  $Worker.worker_name,
  $Worker.company_name,
  $Plan.theme,
  $Worker.role,
  $Worker.mission,
  $Worker.tone,
  $Worker.risk_tolerance,
  $Worker.verbosity,
  $PrototypePromptPath,
  $EvaluationPath,
  $ReviewPath,
  $Plan.hypothesis,
  ((@($Plan.prompt_adjustments) | ForEach-Object { "- $_" }) -join "`n"),
  ((@($Plan.pass_signals) | ForEach-Object { "- $_" }) -join "`n")

Write-Utf8NoBomFile -Path $PlanPath -Content ($Content.TrimStart() + "`n")

$NextState = $null
if (-not $ExplicitWorker) {
  $NextState = [ordered]@{
    version = "v1"
    last_generated_at = $Timestamp.ToString("o")
    last_worker_key = $WorkerKey
    next_index = (($NextIndex + 1) % $WorkerKeys.Count)
  }

  Write-Utf8NoBomFile -Path $StatePath -Content ((($NextState | ConvertTo-Json -Depth 10)) + "`n")
}

$LogRecord = [ordered]@{
  timestamp = $Timestamp.ToString("o")
  event = "worker_lab_plan_created"
  worker_key = $WorkerKey
  path = $PlanPath
  next_index = if ($NextState) { $NextState.next_index } else { $NextIndex }
  explicit_worker = $ExplicitWorker
}

Append-Utf8NoBomLine -Path $LogPath -Line ($LogRecord | ConvertTo-Json -Depth 10 -Compress)
Write-Output "created worker lab plan: $WorkerKey"
