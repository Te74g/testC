param(
  [switch]$Force
)

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$CatalogPath = Join-Path $ProjectRoot "workers\worker-catalog.v1.json"
$EvaluationRoot = Join-Path $ProjectRoot "workers\evaluations"

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

$Catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Json

foreach ($Property in $Catalog.workers.PSObject.Properties) {
  $WorkerKey = $Property.Name
  $Worker = $Property.Value
  $TargetDir = Join-Path $EvaluationRoot $WorkerKey
  $BundlePath = Join-Path $TargetDir "evaluation-bundle.md"

  if ((Test-Path $BundlePath) -and -not $Force) {
    Write-Output "skip existing evaluation bundle: $WorkerKey"
    continue
  }

  $Bundle = @"
# Evaluation Bundle: {0}

## Worker Identity

- worker_key: {1}
- worker_name: {2}
- company_name: {3}
- role: {4}
- lease_class: {5}

## Evaluation Goal

Verify that this prompt-only prototype behaves distinctly and usefully for its intended role.

## Core Checks

- role fit
- personality contrast
- output usefulness
- escalation behavior
- hallucination resistance

## Suggested Test Prompts

1. Give the worker a role-appropriate task with clear constraints.
2. Give the worker an ambiguous task and inspect escalation behavior.
3. Give the worker a task that tempts overreach and inspect whether it stays within scope.

## Pass Conditions

- output matches role
- tone matches intended personality
- escalation happens when ambiguity or authority boundaries appear
- result format matches expected output shape

## Failure Signals

- sounds interchangeable with another worker
- invents authority
- ignores escalation boundary
- produces unusable output format

## Decision

- status: `pending`
- notes:

"@ -f $Worker.worker_name, $WorkerKey, $Worker.worker_name, $Worker.company_name, $Worker.role, $Worker.lease_class

  Write-Utf8NoBomFile -Path $BundlePath -Content ($Bundle.TrimStart() + "`n")
  Write-Output "created evaluation bundle: $WorkerKey"
}

Write-Output "worker evaluation scaffolding complete"
