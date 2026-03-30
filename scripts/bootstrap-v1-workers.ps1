param(
  [switch]$Force
)

. (Join-Path $PSScriptRoot "resolve-northbridge-path.ps1")

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ControlPath = Resolve-NorthbridgeControlPath -ProjectRoot $ProjectRoot -RequireExisting
if (-not (Test-Path $ControlPath)) {
  $Candidates = Get-NorthbridgeRootCandidates -ProjectRoot $ProjectRoot
  throw "guarded relay control not found. candidates: $($Candidates -join ', ')"
}

$PrototypeRoot = Join-Path $ProjectRoot "workers\prototypes"

$Seeds = @(
  @{ worker_key = "W-01-builder"; receiver = "Northbridge Systems"; reason = "seed Builder prompt-only prototype" },
  @{ worker_key = "W-02-verifier"; receiver = "Northbridge Systems"; reason = "seed Verifier prompt-only prototype" },
  @{ worker_key = "W-03-researcher"; receiver = "Claude-side company"; reason = "seed Researcher prompt-only prototype" },
  @{ worker_key = "W-04-editor"; receiver = "Claude-side company"; reason = "seed Editor prompt-only prototype" },
  @{ worker_key = "W-05-watcher"; receiver = "Northbridge Systems"; reason = "seed Watcher prompt-only prototype" }
)

foreach ($Seed in $Seeds) {
  $PrototypeDir = Join-Path $PrototypeRoot $Seed.worker_key
  $ProfilePath = Join-Path $PrototypeDir "profile.json"
  $PromptPath = Join-Path $PrototypeDir "prompt.md"

  if (-not $Force -and (Test-Path $ProfilePath) -and (Test-Path $PromptPath)) {
    Write-Output "skip existing prototype: $($Seed.worker_key)"
    continue
  }

  powershell -ExecutionPolicy Bypass -File $ControlPath `
    -Action Enqueue `
    -Command nc.worker.seed `
    -Sender "Northbridge Systems" `
    -Receiver $Seed.receiver `
    -Reason $Seed.reason `
    -WorkerKey $Seed.worker_key `
    -PrototypeStage prompt_only
}

Write-Output "worker bootstrap pass complete"
