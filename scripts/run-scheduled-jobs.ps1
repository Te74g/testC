param()

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ConfigPath = Join-Path $ProjectRoot "runtime\config\scheduled-jobs.v1.json"
$StatePath = Join-Path $ProjectRoot "runtime\state\scheduled-jobs.state.json"
$NorthbridgeDreamStatePath = Join-Path $ProjectRoot "runtime\state\northbridge-dream.state.json"

function Write-Utf8NoBomFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$Content
  )

  $Directory = Split-Path -Parent $Path
  if ($Directory) {
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }

  $Encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $Encoding)
}

function Read-JsonFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  if (-not (Test-Path $Path)) {
    return $null
  }

  return Get-Content $Path -Raw | ConvertFrom-Json
}

function Write-JsonFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [object]$Value
  )

  $Json = $Value | ConvertTo-Json -Depth 12
  Write-Utf8NoBomFile -Path $Path -Content ($Json + "`n")
}

function Get-AnchorTime {
  param(
    [Parameter(Mandatory = $true)]
    [object]$Job,

    [Parameter(Mandatory = $true)]
    [object]$JobState
  )

  $Anchor = $null
  if ($JobState.Contains("last_finished_at") -and $JobState.last_finished_at) {
    $Anchor = [datetime]$JobState.last_finished_at
  } elseif ($JobState.Contains("last_completed_at") -and $JobState.last_completed_at) {
    $Anchor = [datetime]$JobState.last_completed_at
  }

  if ([string]$Job.job_id -eq "northbridge_dream" -and (Test-Path $NorthbridgeDreamStatePath)) {
    $DreamState = Read-JsonFile -Path $NorthbridgeDreamStatePath
    if ($DreamState -and $DreamState.last_completed_at) {
      $DreamCompletedAt = [datetime]$DreamState.last_completed_at
      if ($null -eq $Anchor -or $DreamCompletedAt -gt $Anchor) {
        $Anchor = $DreamCompletedAt
        $JobState.last_completed_at = $DreamState.last_completed_at
      }
    }
  }

  return $Anchor
}

$Config = Read-JsonFile -Path $ConfigPath
if (-not $Config) {
  throw "scheduled jobs config not found: $ConfigPath"
}

$ExistingState = Read-JsonFile -Path $StatePath
$JobsState = [ordered]@{}
if ($ExistingState -and $ExistingState.jobs) {
  foreach ($Property in $ExistingState.jobs.PSObject.Properties) {
    $JobsState[$Property.Name] = [ordered]@{}
    foreach ($InnerProperty in $Property.Value.PSObject.Properties) {
      $JobsState[$Property.Name][$InnerProperty.Name] = $InnerProperty.Value
    }
  }
}

$Results = New-Object System.Collections.Generic.List[string]
$Now = Get-Date

foreach ($Job in $Config.jobs) {
  $JobId = [string]$Job.job_id
  if (-not $JobsState.Contains($JobId)) {
    $JobsState[$JobId] = [ordered]@{}
  }

  $JobState = $JobsState[$JobId]
  $JobState.enabled = [bool]$Job.enabled
  $JobState.script_name = [string]$Job.script_name
  $JobState.min_interval_minutes = [int]$Job.min_interval_minutes

  if (-not [bool]$Job.enabled) {
    $JobState.last_status = "disabled"
    $Results.Add(("{0}: disabled" -f $JobId)) | Out-Null
    continue
  }

  $AnchorTime = Get-AnchorTime -Job $Job -JobState $JobState

  $Due = $true
  if ($AnchorTime) {
    $ElapsedMinutes = ($Now - $AnchorTime).TotalMinutes
    $Due = $ElapsedMinutes -ge [int]$Job.min_interval_minutes
    $JobState.last_anchor_at = $AnchorTime.ToString("o")
    $JobState.next_due_at = $AnchorTime.AddMinutes([int]$Job.min_interval_minutes).ToString("o")
  }

  if (-not $Due) {
    $JobState.last_status = "not_due"
    $Results.Add(("{0}: not due" -f $JobId)) | Out-Null
    continue
  }

  $ScriptPath = Join-Path $PSScriptRoot ([string]$Job.script_name)
  if (-not (Test-Path $ScriptPath)) {
    $JobState.last_status = "failed"
    $JobState.last_error = "missing script"
    $Results.Add(("{0}: missing script" -f $JobId)) | Out-Null
    continue
  }

  $JobState.last_started_at = $Now.ToString("o")
  try {
    $Output = & $ScriptPath 2>&1
    $Lines = @($Output | ForEach-Object { "$_" } | Where-Object { $_ -ne "" })

    $LastLine = if ($Lines.Count -gt 0) { $Lines[-1] } else { "" }
    $FinishedAt = (Get-Date).ToString("o")
    $JobState.last_finished_at = $FinishedAt
    $JobState.next_due_at = (Get-Date).AddMinutes([int]$Job.min_interval_minutes).ToString("o")
    if ($LastLine -like "*skipped:*") {
      $JobState.last_status = "skipped"
      $JobState.last_skip_reason = ($LastLine -replace '^.*skipped:\s*', '').Trim()
    } else {
      $JobState.last_status = "completed"
      $JobState.last_completed_at = $FinishedAt
      $JobState.last_skip_reason = $null
    }
    $JobState.last_output = $Lines
    $JobState.last_error = $null
    $Results.Add(("{0}: {1}" -f $JobId, $JobState.last_status)) | Out-Null
  } catch {
    $JobState.last_status = "failed"
    $JobState.last_error = $_.Exception.Message
    $JobState.last_output = @()
    $Results.Add(("{0}: failed" -f $JobId)) | Out-Null
  }
}

$State = [ordered]@{
  version = "v1"
  last_scheduler_run_at = (Get-Date).ToString("o")
  jobs = $JobsState
}

Write-JsonFile -Path $StatePath -Value $State
Write-Output ($Results -join "; ")
