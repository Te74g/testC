param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$HeartbeatRoot = Join-Path $ProjectRoot "runtime\state\work-heartbeat"
$LatestPath = Join-Path $HeartbeatRoot "latest.json"
$HistoryPath = Join-Path $HeartbeatRoot "history.jsonl"
$RelayStatusPath = Join-Path $ProjectRoot "runtime\state\relay-bot.status.json"
$WorkersPrototypeRoot = Join-Path $ProjectRoot "workers\prototypes"
$WorkersEvaluationRoot = Join-Path $ProjectRoot "workers\evaluations"
$WorkersReviewRoot = Join-Path $ProjectRoot "workers\reviews"
$WorkersLabRoot = Join-Path $ProjectRoot "workers\lab"
$WorkersTrainingRoot = Join-Path $ProjectRoot "workers\training"
$PresidentInboxRoot = Join-Path $ProjectRoot "runtime\inbox\president"

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

$RelayStatus = $null
if (Test-Path $RelayStatusPath) {
  $RelayStatus = Get-Content $RelayStatusPath -Raw | ConvertFrom-Json
}

$Record = [ordered]@{
  timestamp = (Get-Date).ToString("o")
  relay_status = $RelayStatus
  prototype_count = (Get-ChildItem $WorkersPrototypeRoot -Directory -ErrorAction SilentlyContinue | Measure-Object).Count
  evaluation_count = (Get-ChildItem $WorkersEvaluationRoot -Recurse -Filter evaluation-bundle.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  promotion_review_count = (Get-ChildItem $WorkersReviewRoot -Recurse -Filter promotion-review.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  worker_lab_plan_count = (Get-ChildItem $WorkersLabRoot -Recurse -Filter *-iteration-plan.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  training_brief_count = (Get-ChildItem $WorkersTrainingRoot -Recurse -Filter *-training-brief.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  prompt_revision_candidate_count = (Get-ChildItem $WorkersTrainingRoot -Recurse -Filter *-prompt-revision-candidate.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
  president_inbox_message_count = (Get-ChildItem $PresidentInboxRoot -Filter *.md -File -ErrorAction SilentlyContinue | Measure-Object).Count
}

$Json = ($Record | ConvertTo-Json -Depth 10)
Write-Utf8NoBomFile -Path $LatestPath -Content ($Json + "`n")
Append-Utf8NoBomLine -Path $HistoryPath -Line ($Record | ConvertTo-Json -Depth 10 -Compress)

Write-Output "bot work heartbeat written"
