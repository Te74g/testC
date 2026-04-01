param(
  [Parameter(Mandatory = $true)]
  [string]$WorkerKey,
  [switch]$Force,
  [switch]$InProcess
)

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

function Invoke-CheckedScript {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptName,

    [Parameter(Mandatory = $true)]
    [string]$WorkerKey,

    [switch]$Force,

    [string[]]$ExtraArguments = @()
  )

  $Arguments = @("-WorkerKey", $WorkerKey)
  if ($Force) {
    $Arguments += "-Force"
  }
  if ($ExtraArguments.Count -gt 0) {
    $Arguments += $ExtraArguments
  }

  $ScriptPath = Join-Path $ScriptRoot $ScriptName
  if ($InProcess) {
    try {
      $InvokeArguments = @{
        WorkerKey = $WorkerKey
        Force = [bool]$Force
      }
      for ($Index = 0; $Index -lt $ExtraArguments.Count; $Index += 2) {
        $NameToken = $ExtraArguments[$Index]
        if (-not $NameToken.StartsWith("-")) {
          throw "unsupported in-process argument token for ${ScriptName}: $NameToken"
        }
        if ($Index + 1 -ge $ExtraArguments.Count) {
          throw "missing value for in-process argument ${NameToken} in ${ScriptName}"
        }
        $ArgumentName = $NameToken.TrimStart("-")
        $InvokeArguments[$ArgumentName] = $ExtraArguments[$Index + 1]
      }
      $Output = & $ScriptPath @InvokeArguments 2>&1
    } catch {
      throw "$ScriptName failed for ${WorkerKey}: $($_.Exception.Message)"
    }
  } else {
    $Command = @(
      "-ExecutionPolicy", "Bypass",
      "-File", $ScriptPath
    ) + $Arguments

    $Output = & powershell @Command
    if ($LASTEXITCODE -ne 0) {
      throw "$ScriptName failed for $WorkerKey with exit code $LASTEXITCODE"
    }
  }

  if ($Output) {
    $Output
  }
}

Invoke-CheckedScript -ScriptName "advance-worker-lab.ps1" -WorkerKey $WorkerKey -Force:$Force
Invoke-CheckedScript -ScriptName "draft-worker-training-pack.ps1" -WorkerKey $WorkerKey -Force:$Force
$CanAdvancePatchFlow = $true
try {
  Invoke-CheckedScript -ScriptName "run-local-worker-evaluation.ps1" -WorkerKey $WorkerKey -Force:$Force -ExtraArguments @("-Mode", "smoke")
} catch {
  if ($_.Exception.Message -match "LOCAL_LLM_UNREACHABLE") {
    $CanAdvancePatchFlow = $false
    Write-Output "soft block: local LLM unavailable for $WorkerKey; skipping prompt patch flow until runtime health recovers"
  } else {
    throw
  }
}

if ($CanAdvancePatchFlow) {
  Invoke-CheckedScript -ScriptName "draft-worker-patch-proposal.ps1" -WorkerKey $WorkerKey -Force:$Force
  Invoke-CheckedScript -ScriptName "render-worker-prompt-preview.ps1" -WorkerKey $WorkerKey -Force:$Force
  Invoke-CheckedScript -ScriptName "draft-worker-patch-approval-request.ps1" -WorkerKey $WorkerKey -Force:$Force
} else {
  Write-Output "worker lane degraded mode: $WorkerKey"
}

Write-Output "worker lane complete: $WorkerKey"
