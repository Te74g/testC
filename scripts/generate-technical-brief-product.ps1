param(
  [Parameter(Mandatory = $true)]
  [string]$IntakePath,

  [string]$OutputDir = "",
  [string]$Model = "",
  [int]$TimeoutMs = 240000
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$GeneratorPath = Join-Path $ProjectRoot "runtime\technical-brief-generator.js"

if (-not (Test-Path $GeneratorPath)) {
  throw "technical brief generator not found at $GeneratorPath"
}

$Arguments = @($GeneratorPath, "--intake", $IntakePath)
if ($OutputDir) {
  $Arguments += @("--output-dir", $OutputDir)
}
if ($Model) {
  $Arguments += @("--model", $Model)
}
if ($TimeoutMs -gt 0) {
  $Arguments += @("--timeout-ms", [string]$TimeoutMs)
}

& node @Arguments
if ($LASTEXITCODE -ne 0) {
  throw "technical brief generation failed with exit code $LASTEXITCODE"
}

Write-Output "technical brief product generation complete"
