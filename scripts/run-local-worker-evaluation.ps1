param(
  [Parameter(Mandatory = $true)]
  [string]$WorkerKey,
  [ValidateSet("smoke", "full")]
  [string]$Mode = "full",
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$NodeScriptPath = Join-Path $ProjectRoot "runtime\local-eval-runner.js"
$CasesPath = Join-Path $ProjectRoot ("workers\evaluations\{0}\cases.v1.json" -f $WorkerKey)
$OutputRoot = Join-Path $ProjectRoot ("workers\local-evaluations\{0}" -f $WorkerKey)

if (-not (Test-Path $NodeScriptPath)) {
  throw "local eval runner not found at $NodeScriptPath"
}

if (-not (Test-Path $CasesPath)) {
  throw "local evaluation cases not found at $CasesPath"
}

$NodePath = (Get-Command node -ErrorAction Stop).Source
$Arguments = @(
  $NodeScriptPath,
  "--worker-key", $WorkerKey,
  "--mode", $Mode
)

if ($Force) {
  $Arguments += "--force"
}

$Output = & $NodePath @Arguments 2>&1

if ($Output) {
  $Output
}

if ($LASTEXITCODE -ne 0) {
  $FailureCode = "unknown"
  $FailureMessage = "no diagnostic record found"
  if (Test-Path $OutputRoot) {
    $LatestJson = Get-ChildItem $OutputRoot -Filter ("*-{0}-local-eval.json" -f $Mode) -File -ErrorAction SilentlyContinue |
      Sort-Object LastWriteTime -Descending |
      Select-Object -First 1
    if ($LatestJson) {
      $Record = Get-Content $LatestJson.FullName -Raw | ConvertFrom-Json
      if ($Record.results -and $Record.results.Count -gt 0) {
        $FirstResult = $Record.results[0]
        if ($FirstResult.error_details -and $FirstResult.error_details.code) {
          $FailureCode = [string]$FirstResult.error_details.code
        }
        if ($FirstResult.error) {
          $FailureMessage = [string]$FirstResult.error
        }
      }
    }
  }
  throw "local worker evaluation failed for $WorkerKey ($Mode): $FailureCode - $FailureMessage"
}
