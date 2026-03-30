param()

$ControlPath = Join-Path ([Environment]::GetFolderPath("UserProfile")) ".northbridge\northbridge-relay-control.ps1"
if (-not (Test-Path $ControlPath)) {
  throw "guarded relay control not found at $ControlPath"
}

$Seeds = @(
  @{ worker_key = "W-01-builder"; receiver = "Northbridge Systems"; reason = "seed Builder prompt-only prototype" },
  @{ worker_key = "W-02-verifier"; receiver = "Northbridge Systems"; reason = "seed Verifier prompt-only prototype" },
  @{ worker_key = "W-03-researcher"; receiver = "Claude-side company"; reason = "seed Researcher prompt-only prototype" },
  @{ worker_key = "W-04-editor"; receiver = "Claude-side company"; reason = "seed Editor prompt-only prototype" },
  @{ worker_key = "W-05-watcher"; receiver = "Northbridge Systems"; reason = "seed Watcher prompt-only prototype" }
)

foreach ($Seed in $Seeds) {
  powershell -ExecutionPolicy Bypass -File $ControlPath `
    -Action Enqueue `
    -Command nc.worker.seed `
    -Sender "Northbridge Systems" `
    -Receiver $Seed.receiver `
    -Reason $Seed.reason `
    -WorkerKey $Seed.worker_key `
    -PrototypeStage prompt_only
}

Write-Output "worker bootstrap commands enqueued"
