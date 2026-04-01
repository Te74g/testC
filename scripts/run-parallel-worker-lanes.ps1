param(
  [int]$MaxWorkers = 10,
  [switch]$Force,
  [switch]$InProcess
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$CatalogPath = Join-Path $ProjectRoot "workers\worker-catalog.v1.json"
$LogRoot = Join-Path $ProjectRoot "runtime\logs\parallel-worker-lanes"

function Start-WorkerLaneProcess {
  param(
    [Parameter(Mandatory = $true)]
    [string]$WorkerKey,

    [switch]$Force
  )

  $StdOutPath = Join-Path $LogRoot ("{0}-stdout.log" -f $WorkerKey)
  $StdErrPath = Join-Path $LogRoot ("{0}-stderr.log" -f $WorkerKey)

  $Args = @(
    "-ExecutionPolicy", "Bypass",
    "-File", (Join-Path $PSScriptRoot "run-worker-lane.ps1"),
    "-WorkerKey", $WorkerKey
  )

  if ($Force) {
    $Args += "-Force"
  }

  $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
  $StartInfo.FileName = (Get-Command powershell -ErrorAction Stop).Source
  $StartInfo.Arguments = ($Args -join " ")
  $StartInfo.WorkingDirectory = $ProjectRoot
  $StartInfo.UseShellExecute = $false
  $StartInfo.CreateNoWindow = $true
  $StartInfo.RedirectStandardOutput = $true
  $StartInfo.RedirectStandardError = $true

  $Process = New-Object System.Diagnostics.Process
  $Process.StartInfo = $StartInfo
  $null = $Process.Start()

  return [pscustomobject]@{
    worker_key = $WorkerKey
    process = $Process
    stdout_path = $StdOutPath
    stderr_path = $StdErrPath
  }
}

function Write-ProcessStreams {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Lane
  )

  [System.IO.File]::WriteAllText($Lane.stdout_path, $Lane.process.StandardOutput.ReadToEnd(), [System.Text.UTF8Encoding]::new($false))
  [System.IO.File]::WriteAllText($Lane.stderr_path, $Lane.process.StandardError.ReadToEnd(), [System.Text.UTF8Encoding]::new($false))
}

New-Item -ItemType Directory -Force -Path $LogRoot | Out-Null

$Catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Json
$WorkerKeys = @($Catalog.workers.PSObject.Properties | ForEach-Object { $_.Name }) | Sort-Object
$TargetWorkers = @($WorkerKeys | Select-Object -First ([Math]::Min($MaxWorkers, $WorkerKeys.Count)))

$Failures = @()
if ($InProcess) {
  foreach ($WorkerKey in $TargetWorkers) {
    try {
      & (Join-Path $PSScriptRoot "run-worker-lane.ps1") -WorkerKey $WorkerKey -Force:$Force -InProcess
    } catch {
      $Failures += $WorkerKey
    }
  }

  & (Join-Path $PSScriptRoot "backfill-worker-patch-review-artifacts.ps1") | Out-Null
  & (Join-Path $PSScriptRoot "render-patch-review-board.ps1") | Out-Null
  & (Join-Path $PSScriptRoot "render-worker-patch-batch-decision-brief.ps1") | Out-Null
  & (Join-Path $PSScriptRoot "render-primary-live-patch-readiness.ps1") | Out-Null
  & (Join-Path $PSScriptRoot "render-primary-live-patch-pack.ps1") | Out-Null
} else {
  $Lanes = @()
  foreach ($WorkerKey in $TargetWorkers) {
    $Lanes += Start-WorkerLaneProcess -WorkerKey $WorkerKey -Force:$Force
  }

  foreach ($Lane in $Lanes) {
    $Lane.process.WaitForExit()
    Write-ProcessStreams -Lane $Lane

    if ($Lane.process.ExitCode -ne 0) {
      $Failures += $Lane.worker_key
    }
  }

  & powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "backfill-worker-patch-review-artifacts.ps1") | Out-Null
  & powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "render-patch-review-board.ps1") | Out-Null
  & powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "render-worker-patch-batch-decision-brief.ps1") | Out-Null
  & powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "render-primary-live-patch-readiness.ps1") | Out-Null
  & powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "render-primary-live-patch-pack.ps1") | Out-Null
}

if ($Failures.Count -gt 0) {
  throw ("parallel worker lanes failed for: {0}" -f ($Failures -join ", "))
}

Write-Output ("parallel worker lanes complete: workers={0}" -f ($TargetWorkers -join ", "))
