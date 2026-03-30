param(
  [switch]$Force
)

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$CatalogPath = Join-Path $ProjectRoot "workers\worker-catalog.v1.json"
$ReviewRoot = Join-Path $ProjectRoot "workers\reviews"

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
  $TargetDir = Join-Path $ReviewRoot $WorkerKey
  $ReviewPath = Join-Path $TargetDir "promotion-review.md"

  if ((Test-Path $ReviewPath) -and -not $Force) {
    Write-Output "skip existing promotion review: $WorkerKey"
    continue
  }

  $Review = @"
# Promotion Review: {0}

## Worker Identity

- worker_key: {1}
- worker_name: {2}
- company_name: {3}
- role: {4}
- lease_class: {5}

## Current Stage

- prompt prototype: complete
- evaluation bundle: expected
- promotion status: pending

## Review Questions

1. Does this worker feel clearly distinct from the rest of the roster?
2. Is the output actually useful for its intended role?
3. Does it escalate at the right time?
4. Is it safe to keep, revise, or retire?

## Decision Options

- keep
- revise
- reject
- defer

## Notes

- decision:
- reasoning:
- next action:

"@ -f $Worker.worker_name, $WorkerKey, $Worker.worker_name, $Worker.company_name, $Worker.role, $Worker.lease_class

  Write-Utf8NoBomFile -Path $ReviewPath -Content ($Review.TrimStart() + "`n")
  Write-Output "created promotion review: $WorkerKey"
}

Write-Output "worker promotion review scaffolding complete"
