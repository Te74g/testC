param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot

powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "bootstrap-v1-workers.ps1")
powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "materialize-worker-prototypes.ps1")

Write-Output "daily worker cycle complete"
