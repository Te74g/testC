param()

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

function Invoke-CheckedScript {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptName
  )

  $Output = powershell -ExecutionPolicy Bypass -File (Join-Path $ScriptRoot $ScriptName)
  if ($LASTEXITCODE -ne 0) {
    throw "$ScriptName failed with exit code $LASTEXITCODE"
  }

  if ($Output) {
    $Output
  }
}

Invoke-CheckedScript -ScriptName "ensure-relay-bot.ps1"
Invoke-CheckedScript -ScriptName "bootstrap-v1-workers.ps1"
Start-Sleep -Seconds 2
Invoke-CheckedScript -ScriptName "materialize-worker-prototypes.ps1"
Invoke-CheckedScript -ScriptName "scaffold-worker-evaluations.ps1"
Invoke-CheckedScript -ScriptName "scaffold-worker-promotion-reviews.ps1"

Write-Output "continue bot work cycle complete"
