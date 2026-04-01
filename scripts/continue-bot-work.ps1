param(
  [switch]$InProcess
)

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptRoot
$RuntimeSettingsPath = Join-Path $ProjectRoot "runtime\config\runtime-settings.v1.json"

function Invoke-CheckedScript {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptName,

    [string[]]$Arguments = @()
  )

  $ScriptPath = Join-Path $ScriptRoot $ScriptName
  if ($InProcess) {
    if ($Arguments.Count -gt 0) {
      throw "$ScriptName does not support tokenized in-process arguments"
    }
    try {
      $Output = & $ScriptPath 2>&1
    } catch {
      throw "$ScriptName failed: $($_.Exception.Message)"
    }
  } else {
    $Command = @(
      "-ExecutionPolicy", "Bypass",
      "-File", $ScriptPath
    ) + $Arguments

    $Output = & powershell @Command
    if ($LASTEXITCODE -ne 0) {
      throw "$ScriptName failed with exit code $LASTEXITCODE"
    }
  }

  if ($Output) {
    $Output
  }
}

function Invoke-CheckedScriptWithArgs {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptName,

    [string[]]$Arguments = @()
  )

  Invoke-CheckedScript -ScriptName $ScriptName -Arguments $Arguments
}

$RuntimeSettings = $null
if (Test-Path $RuntimeSettingsPath) {
  $RuntimeSettings = Get-Content $RuntimeSettingsPath -Raw | ConvertFrom-Json
}

$EffectiveLanes = 1
if ($RuntimeSettings -and $null -ne $RuntimeSettings.current_effective_worker_lanes) {
  $EffectiveLanes = [int]$RuntimeSettings.current_effective_worker_lanes
}

Invoke-CheckedScript -ScriptName "ensure-relay-bot.ps1"
Invoke-CheckedScript -ScriptName "bootstrap-v1-workers.ps1"
Start-Sleep -Seconds 2
Invoke-CheckedScript -ScriptName "materialize-worker-prototypes.ps1"
Invoke-CheckedScript -ScriptName "scaffold-worker-evaluations.ps1"
Invoke-CheckedScript -ScriptName "scaffold-local-evaluation-cases.ps1"
Invoke-CheckedScript -ScriptName "scaffold-worker-promotion-reviews.ps1"

if ($EffectiveLanes -gt 1) {
  if ($InProcess) {
    try {
      $LaneOutput = & (Join-Path $ScriptRoot "run-parallel-worker-lanes.ps1") -MaxWorkers $EffectiveLanes -InProcess 2>&1
    } catch {
      throw "run-parallel-worker-lanes.ps1 failed: $($_.Exception.Message)"
    }
    if ($LaneOutput) {
      $LaneOutput
    }
  } else {
    Invoke-CheckedScriptWithArgs -ScriptName "run-parallel-worker-lanes.ps1" -Arguments @("-MaxWorkers", [string]$EffectiveLanes)
  }
} else {
  Invoke-CheckedScript -ScriptName "advance-worker-lab.ps1"
  Invoke-CheckedScript -ScriptName "draft-worker-training-pack.ps1"
  Invoke-CheckedScript -ScriptName "draft-worker-patch-proposal.ps1"
  Invoke-CheckedScript -ScriptName "render-worker-prompt-preview.ps1"
  Invoke-CheckedScript -ScriptName "draft-worker-patch-approval-request.ps1"
  Invoke-CheckedScript -ScriptName "backfill-worker-patch-review-artifacts.ps1"
  Invoke-CheckedScript -ScriptName "render-patch-review-board.ps1"
  Invoke-CheckedScript -ScriptName "render-worker-patch-batch-decision-brief.ps1"
  Invoke-CheckedScript -ScriptName "render-primary-live-patch-readiness.ps1"
  Invoke-CheckedScript -ScriptName "render-primary-live-patch-pack.ps1"
}

Invoke-CheckedScript -ScriptName "run-scheduled-jobs.ps1"
Invoke-CheckedScript -ScriptName "check-local-llm-runtime.ps1"
Invoke-CheckedScript -ScriptName "write-bot-work-heartbeat.ps1"
Invoke-CheckedScript -ScriptName "write-president-message.ps1"

Write-Output "continue bot work cycle complete"
