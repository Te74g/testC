param(
  [Parameter(Mandatory = $true)]
  [string]$DeliveryPath,

  [string]$IntakePath = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ReviewerPath = Join-Path $ProjectRoot "runtime\technical-brief-reviewer.js"

if (-not (Test-Path $ReviewerPath)) {
  throw "technical brief reviewer not found at $ReviewerPath"
}

$Arguments = @($ReviewerPath, "--delivery", $DeliveryPath)
if ($IntakePath) {
  $Arguments += @("--intake", $IntakePath)
}

& node @Arguments
if ($LASTEXITCODE -ne 0) {
  throw "technical brief review failed with exit code $LASTEXITCODE"
}

Write-Output "technical brief product review complete"
