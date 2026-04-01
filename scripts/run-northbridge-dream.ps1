param(
  [switch]$Force
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DreamConfigPath = Join-Path $ProjectRoot "runtime\config\northbridge-dream.v1.json"
$DreamStatePath = Join-Path $ProjectRoot "runtime\state\northbridge-dream.state.json"
$DreamLockPath = Join-Path $ProjectRoot "runtime\state\northbridge-dream.lock"
$DreamReportRoot = Join-Path $ProjectRoot "runtime\dream\reports"
$DreamLatestPath = Join-Path $ProjectRoot "runtime\dream\latest.md"
$HeartbeatPath = Join-Path $ProjectRoot "runtime\state\work-heartbeat\latest.json"
$SupervisorStatusPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.status.json"
$PresidentInboxRoot = Join-Path $ProjectRoot "runtime\inbox\president"
$LocalEvaluationRoot = Join-Path $ProjectRoot "workers\local-evaluations"
$ActiveContextPath = Join-Path $ProjectRoot "memory\ACTIVE_CONTEXT.md"
$DurableMemoryPath = Join-Path $ProjectRoot "memory\DURABLE_MEMORY.md"

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

function Test-ProcessAlive {
  param(
    [int]$PidValue
  )

  if ($PidValue -le 0) {
    return $false
  }

  $Process = Get-Process -Id $PidValue -ErrorAction SilentlyContinue
  return $null -ne $Process
}

function Try-AcquireDreamLock {
  param(
    [int]$StaleMinutes = 60
  )

  $LockDirectory = Split-Path -Parent $DreamLockPath
  if ($LockDirectory) {
    New-Item -ItemType Directory -Force -Path $LockDirectory | Out-Null
  }

  $ExistingPid = $null
  $ExistingMtime = $null
  if (Test-Path $DreamLockPath) {
    try {
      $ExistingPidText = Get-Content $DreamLockPath -Raw -ErrorAction Stop
      $ParsedPid = 0
      if ([int]::TryParse($ExistingPidText.Trim(), [ref]$ParsedPid)) {
        $ExistingPid = $ParsedPid
      }
    } catch {
    }

    try {
      $ExistingMtime = (Get-Item $DreamLockPath -ErrorAction Stop).LastWriteTime
    } catch {
    }
  }

  if ($ExistingMtime) {
    $AgeMinutes = ((Get-Date) - $ExistingMtime).TotalMinutes
    if ($AgeMinutes -lt $StaleMinutes -and $ExistingPid -and (Test-ProcessAlive -PidValue $ExistingPid)) {
      return [pscustomobject]@{
        acquired = $false
        reason = "lock_held"
        holder_pid = $ExistingPid
        holder_age_minutes = [math]::Round($AgeMinutes, 2)
      }
    }
  }

  Write-Utf8NoBomFile -Path $DreamLockPath -Content ("{0}" -f $PID)

  $VerifyPidText = Get-Content $DreamLockPath -Raw -ErrorAction SilentlyContinue
  $VerifyPid = 0
  if (-not [int]::TryParse($VerifyPidText.Trim(), [ref]$VerifyPid) -or $VerifyPid -ne $PID) {
    return [pscustomobject]@{
      acquired = $false
      reason = "lock_race"
      holder_pid = $VerifyPid
      holder_age_minutes = 0
    }
  }

  return [pscustomobject]@{
    acquired = $true
    reason = "acquired"
    holder_pid = $PID
    holder_age_minutes = 0
  }
}

function Release-DreamLock {
  if (-not (Test-Path $DreamLockPath)) {
    return
  }

  try {
    $LockPidText = Get-Content $DreamLockPath -Raw -ErrorAction SilentlyContinue
    $LockPid = 0
    if ([int]::TryParse($LockPidText.Trim(), [ref]$LockPid) -and $LockPid -eq $PID) {
      Remove-Item $DreamLockPath -Force -ErrorAction SilentlyContinue
    }
  } catch {
  }
}

function Get-TextFileMetrics {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  if (-not (Test-Path $Path)) {
    return [pscustomobject]@{
      exists = $false
      line_count = 0
      byte_count = 0
    }
  }

  $Content = Get-Content $Path -Raw
  return [pscustomobject]@{
    exists = $true
    line_count = @($Content -split "`r?`n").Count
    byte_count = [System.Text.Encoding]::UTF8.GetByteCount($Content)
  }
}

function Get-RecentFiles {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [Parameter(Mandatory = $true)]
    [string]$Filter,

    [int]$MaxCount = 5
  )

  if (-not (Test-Path $Root)) {
    return @()
  }

  return @(Get-ChildItem $Root -Recurse -File -Filter $Filter -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First $MaxCount)
}

function Get-NewFilesSince {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [Parameter(Mandatory = $true)]
    [string]$Filter,

    [AllowNull()]
    [Nullable[datetime]]$Since
  )

  if (-not (Test-Path $Root)) {
    return @()
  }

  $Files = Get-ChildItem $Root -Recurse -File -Filter $Filter -ErrorAction SilentlyContinue
  if ($null -eq $Since) {
    return @($Files)
  }

  return @($Files | Where-Object { $_.LastWriteTime -gt $Since })
}

function Get-MarkdownBulletValue {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Text,

    [Parameter(Mandatory = $true)]
    [string]$Key
  )

  $Pattern = '(?m)^- ' + [regex]::Escape($Key) + ':\s*(.+)$'
  $Match = [regex]::Match($Text, $Pattern)
  if ($Match.Success) {
    return $Match.Groups[1].Value.Trim()
  }

  return $null
}

function Get-ActiveContextObjective {
  if (-not (Test-Path $ActiveContextPath)) {
    return "not_available"
  }

  $Text = Get-Content $ActiveContextPath -Raw
  $Match = [regex]::Match($Text, '(?ms)^## 1\. Current Objective\s+(.+?)(?:\r?\n## |\z)')
  if (-not $Match.Success) {
    return "not_available"
  }

  $Lines = @($Match.Groups[1].Value -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
  if ($Lines.Count -eq 0) {
    return "not_available"
  }

  return $Lines[0]
}

function Get-ActiveNextSteps {
  $Output = @()
  if (-not (Test-Path $ActiveContextPath)) {
    return $Output
  }

  $Text = Get-Content $ActiveContextPath -Raw
  $Match = [regex]::Match($Text, '(?ms)^## 4\. Likely Next Steps\s+(.+?)(?:\r?\n## |\z)')
  if (-not $Match.Success) {
    return $Output
  }

  $Lines = @($Match.Groups[1].Value -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -like "- *" })
  foreach ($Line in $Lines) {
    if ($Output.Count -ge 3) {
      break
    }
    $Output += $Line.Substring(2).Trim()
  }

  return $Output
}

function Parse-LocalEvaluationReport {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$File
  )

  $Text = Get-Content $File.FullName -Raw
  $Worker = Get-MarkdownBulletValue -Text $Text -Key "worker_display_name"
  $Status = Get-MarkdownBulletValue -Text $Text -Key "overall_status"
  $Passed = Get-MarkdownBulletValue -Text $Text -Key "passed_cases"
  $Mode = Get-MarkdownBulletValue -Text $Text -Key "mode"

  $MissingExpectedTerms = @([regex]::Matches($Text, '(?m)^- missing_expected_terms:\s*(.+)$') | ForEach-Object { $_.Groups[1].Value.Trim() } | Where-Object { $_ -and $_ -ne "none" })
  $MissingFields = @([regex]::Matches($Text, '(?m)^- missing_fields:\s*(.+)$') | ForEach-Object { $_.Groups[1].Value.Trim() } | Where-Object { $_ -and $_ -ne "none" })
  $FailedCases = @([regex]::Matches($Text, '(?m)^###\s+(.+)$') | ForEach-Object { $_.Groups[1].Value.Trim() })
  $FailureStatuses = @([regex]::Matches($Text, '(?m)^- status:\s*fail$')).Count

  $IssueHints = @()
  foreach ($Value in $MissingExpectedTerms) {
    $IssueHints += "missing expected terms: $Value"
  }
  foreach ($Value in $MissingFields) {
    $IssueHints += "missing fields: $Value"
  }
  if ($IssueHints.Count -eq 0 -and $FailureStatuses -gt 0) {
    $IssueHints += "failed cases present without a cleaner structured issue label"
  }

  return [pscustomobject]@{
    file_name = $File.Name
    relative_path = $File.FullName.Replace($ProjectRoot + "\", "")
    last_write_at = $File.LastWriteTime.ToString("o")
    worker_display_name = if ($Worker) { $Worker } else { $File.Directory.Name }
    overall_status = if ($Status) { $Status } else { "unknown" }
    passed_cases = if ($Passed) { $Passed } else { "unknown" }
    mode = if ($Mode) { $Mode } else { "unknown" }
    failed_case_count = $FailureStatuses
    issue_hints = $IssueHints
  }
}

function Get-DreamRecommendations {
  param(
    [Parameter(Mandatory = $true)]
    [object[]]$EvaluationSummaries,

    [Parameter(Mandatory = $true)]
    [object]$ActiveMemoryMetrics,

    [Parameter(Mandatory = $true)]
    [object]$DurableMemoryMetrics,

    [int]$MemoryIndexMaxLines = 200,

    [int]$MemoryIndexMaxBytes = 25000
  )

  $Recommendations = New-Object System.Collections.Generic.List[string]

  foreach ($Summary in $EvaluationSummaries) {
    $WorkerName = [string]$Summary.worker_display_name
    $Issues = @($Summary.issue_hints)
    $IssuesText = ($Issues -join " | ")

    if ($WorkerName -like "Ledger*") {
      $Recommendations.Add("Tighten Ledger so bounded fact/inference/unknown checks do not escalate by default, and keep the required markdown contract under pressure.")
      continue
    }

    if ($WorkerName -like "Compass*") {
      $Recommendations.Add("Tighten Compass so missing task language, latency target, or VRAM constraints cause escalation instead of a generic model recommendation.")
      continue
    }

    if ($WorkerName -like "Quill*") {
      $Recommendations.Add("Tighten Quill so every concise brief ends with an explicit next action and unresolved risk.")
      continue
    }

    if ($IssuesText) {
      $Recommendations.Add("$WorkerName needs correction based on: $IssuesText")
    }
  }

  if ($ActiveMemoryMetrics.exists -and ($ActiveMemoryMetrics.line_count -gt $MemoryIndexMaxLines -or $ActiveMemoryMetrics.byte_count -gt $MemoryIndexMaxBytes)) {
    $Recommendations.Add(("Prune ACTIVE_CONTEXT.md; it is at {0} lines / {1} bytes, which is beyond the intended memory index budget." -f $ActiveMemoryMetrics.line_count, $ActiveMemoryMetrics.byte_count))
  }

  if ($DurableMemoryMetrics.exists -and ($DurableMemoryMetrics.line_count -gt $MemoryIndexMaxLines -or $DurableMemoryMetrics.byte_count -gt $MemoryIndexMaxBytes)) {
    $Recommendations.Add(("Prune DURABLE_MEMORY.md; it is at {0} lines / {1} bytes, which is beyond the intended memory index budget." -f $DurableMemoryMetrics.line_count, $DurableMemoryMetrics.byte_count))
  }

  $Recommendations.Add("Keep publication-asset expansion secondary until at least one more full local evaluation exists for the remaining workers.")
  $Recommendations.Add("Use dream reports as recommendation packets only; keep durable-memory edits sponsor-visible and explicit.")

  return @($Recommendations | Select-Object -Unique)
}

$DreamConfig = Read-JsonFile -Path $DreamConfigPath
if (-not $DreamConfig) {
  throw "northbridge dream config not found: $DreamConfigPath"
}

$LockStaleMinutes = 60
if ($null -ne $DreamConfig.lock_stale_minutes) {
  $LockStaleMinutes = [int]$DreamConfig.lock_stale_minutes
}

$MemoryIndexMaxLines = 200
if ($null -ne $DreamConfig.memory_index_max_lines) {
  $MemoryIndexMaxLines = [int]$DreamConfig.memory_index_max_lines
}

$MemoryIndexMaxBytes = 25000
if ($null -ne $DreamConfig.memory_index_max_bytes) {
  $MemoryIndexMaxBytes = [int]$DreamConfig.memory_index_max_bytes
}

$DreamState = Read-JsonFile -Path $DreamStatePath
$Heartbeat = Read-JsonFile -Path $HeartbeatPath
$SupervisorStatus = Read-JsonFile -Path $SupervisorStatusPath

$Now = Get-Date
$LastCompletedAt = $null
if ($DreamState -and $DreamState.last_completed_at) {
  $LastCompletedAt = [datetime]$DreamState.last_completed_at
}

$NewPresidentMessages = Get-NewFilesSince -Root $PresidentInboxRoot -Filter *.md -Since $LastCompletedAt
$NewLocalEvaluations = Get-NewFilesSince -Root $LocalEvaluationRoot -Filter *-local-eval.md -Since $LastCompletedAt

$HoursSinceLast = $null
if ($LastCompletedAt) {
  $HoursSinceLast = ($Now - $LastCompletedAt).TotalHours
}

$TimeGatePassed = $Force.IsPresent -or ($null -eq $HoursSinceLast) -or ($HoursSinceLast -ge [double]$DreamConfig.min_hours_between_runs)
$SignalGatePassed = $Force.IsPresent -or ($NewPresidentMessages.Count -ge [int]$DreamConfig.min_new_president_messages) -or ($NewLocalEvaluations.Count -ge [int]$DreamConfig.min_new_local_evaluations)

$BaseState = [ordered]@{
  version = "v1"
  last_checked_at = $Now.ToString("o")
  last_status = "checked"
  last_completed_at = if ($DreamState) { $DreamState.last_completed_at } else { $null }
  last_report_path = if ($DreamState) { $DreamState.last_report_path } else { $null }
  last_skip_reason = $null
  last_new_president_messages = $NewPresidentMessages.Count
  last_new_local_evaluations = $NewLocalEvaluations.Count
}

if (-not [bool]$DreamConfig.enabled -and -not $Force) {
  $BaseState.last_status = "skipped"
  $BaseState.last_skip_reason = "disabled"
  Write-JsonFile -Path $DreamStatePath -Value $BaseState
  Write-Output "northbridge dream skipped: disabled"
  return
}

if (-not $TimeGatePassed -and -not $Force) {
  $BaseState.last_status = "skipped"
  $BaseState.last_skip_reason = "time_gate"
  Write-JsonFile -Path $DreamStatePath -Value $BaseState
  Write-Output ("northbridge dream skipped: time gate ({0:N1}h < {1}h)" -f $HoursSinceLast, [double]$DreamConfig.min_hours_between_runs)
  return
}

if (-not $SignalGatePassed -and -not $Force) {
  $BaseState.last_status = "skipped"
  $BaseState.last_skip_reason = "signal_gate"
  Write-JsonFile -Path $DreamStatePath -Value $BaseState
  Write-Output ("northbridge dream skipped: signal gate (new president messages={0}, new local evals={1})" -f $NewPresidentMessages.Count, $NewLocalEvaluations.Count)
  return
}

$LockInfo = Try-AcquireDreamLock -StaleMinutes $LockStaleMinutes
if (-not $LockInfo.acquired) {
  $BaseState.last_status = "skipped"
  $BaseState.last_skip_reason = [string]$LockInfo.reason
  $BaseState.last_lock_holder_pid = [int]$LockInfo.holder_pid
  $BaseState.last_lock_holder_age_minutes = [double]$LockInfo.holder_age_minutes
  Write-JsonFile -Path $DreamStatePath -Value $BaseState
  Write-Output ("northbridge dream skipped: {0} (holder_pid={1}, age_minutes={2})" -f $LockInfo.reason, $LockInfo.holder_pid, $LockInfo.holder_age_minutes)
  return
}

$RecentPresidentMessages = Get-RecentFiles -Root $PresidentInboxRoot -Filter *.md -MaxCount ([int]$DreamConfig.max_recent_president_messages)
$RecentLocalEvaluations = Get-RecentFiles -Root $LocalEvaluationRoot -Filter *-local-eval.md -MaxCount ([int]$DreamConfig.max_recent_local_evaluations)
$EvaluationSummaries = @($RecentLocalEvaluations | ForEach-Object { Parse-LocalEvaluationReport -File $_ })
$Objective = Get-ActiveContextObjective
$NextSteps = Get-ActiveNextSteps
$ActiveMemoryMetrics = Get-TextFileMetrics -Path $ActiveContextPath
$DurableMemoryMetrics = Get-TextFileMetrics -Path $DurableMemoryPath
$Recommendations = Get-DreamRecommendations `
  -EvaluationSummaries $EvaluationSummaries `
  -ActiveMemoryMetrics $ActiveMemoryMetrics `
  -DurableMemoryMetrics $DurableMemoryMetrics `
  -MemoryIndexMaxLines $MemoryIndexMaxLines `
  -MemoryIndexMaxBytes $MemoryIndexMaxBytes

try {
  $Stamp = $Now.ToString("yyyyMMdd-HHmmss")
  $ReportName = "{0}-northbridge-dream.md" -f $Stamp
  $ReportPath = Join-Path $DreamReportRoot $ReportName

  $ReportLines = New-Object System.Collections.Generic.List[string]
  $null = $ReportLines.Add("# Northbridge Dream Report")
  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("## Dream Meta")
  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("- created_at: " + $Now.ToString("o"))
  $null = $ReportLines.Add("- trigger_mode: " + $(if ($Force) { "forced" } else { "scheduled" }))
  $null = $ReportLines.Add("- previous_completed_at: " + $(if ($LastCompletedAt) { $LastCompletedAt.ToString("o") } else { "never" }))
  $null = $ReportLines.Add("- new_president_messages: " + $NewPresidentMessages.Count)
  $null = $ReportLines.Add("- new_local_evaluations: " + $NewLocalEvaluations.Count)
  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("## Runtime Snapshot")
  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("- supervisor_state: " + $(if ($SupervisorStatus) { [string]$SupervisorStatus.state } else { "not_available" }))
  $null = $ReportLines.Add("- supervisor_cycle_count: " + $(if ($SupervisorStatus) { [int]$SupervisorStatus.cycle_count } else { 0 }))
  $null = $ReportLines.Add("- approved_parallel_worker_slots: " + $(if ($Heartbeat) { [int]$Heartbeat.approved_parallel_worker_slots } else { 0 }))
  $null = $ReportLines.Add("- current_effective_worker_lanes: " + $(if ($Heartbeat) { [int]$Heartbeat.current_effective_worker_lanes } else { 0 }))
  $null = $ReportLines.Add("- worker_lab_plan_count: " + $(if ($Heartbeat) { [int]$Heartbeat.worker_lab_plan_count } else { 0 }))
  $null = $ReportLines.Add("- local_evaluation_run_count: " + $(if ($Heartbeat) { [int]$Heartbeat.local_evaluation_run_count } else { 0 }))
  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("## Memory Snapshot")
  $null = $ReportLines.Add("")
  $null = $ReportLines.Add(("- ACTIVE_CONTEXT.md: exists={0}, lines={1}, bytes={2}" -f $ActiveMemoryMetrics.exists, $ActiveMemoryMetrics.line_count, $ActiveMemoryMetrics.byte_count))
  $null = $ReportLines.Add(("- DURABLE_MEMORY.md: exists={0}, lines={1}, bytes={2}" -f $DurableMemoryMetrics.exists, $DurableMemoryMetrics.line_count, $DurableMemoryMetrics.byte_count))
  $null = $ReportLines.Add(("- memory_index_budget: max_lines={0}, max_bytes={1}" -f $MemoryIndexMaxLines, $MemoryIndexMaxBytes))
  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("## Current Objective")
  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("- objective: " + $Objective)
  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("## Recent Local Evaluation Evidence")
  $null = $ReportLines.Add("")

  if ($EvaluationSummaries.Count -eq 0) {
    $null = $ReportLines.Add("- no recent local evaluation evidence found")
  } else {
    foreach ($Summary in $EvaluationSummaries) {
      $IssueText = if ($Summary.issue_hints.Count -gt 0) { $Summary.issue_hints -join " | " } else { "no structured issue hints" }
      $null = $ReportLines.Add(("- {0}: status={1}, passed={2}, mode={3}, issue_hints={4}" -f `
        [string]$Summary.worker_display_name,
        [string]$Summary.overall_status,
        [string]$Summary.passed_cases,
        [string]$Summary.mode,
        $IssueText))
      $null = $ReportLines.Add(("  - report: {0}" -f [string]$Summary.relative_path))
    }
  }

  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("## Recent President Inbox Signal")
  $null = $ReportLines.Add("")
  if ($RecentPresidentMessages.Count -eq 0) {
    $null = $ReportLines.Add("- no president inbox messages found")
  } else {
    foreach ($File in $RecentPresidentMessages) {
      $null = $ReportLines.Add(("- {0}" -f $File.FullName.Replace($ProjectRoot + "\", "")))
    }
  }

  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("## Recommended Corrections")
  $null = $ReportLines.Add("")
  foreach ($Recommendation in $Recommendations) {
    $null = $ReportLines.Add("- " + $Recommendation)
  }

  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("## Active Next Steps Snapshot")
  $null = $ReportLines.Add("")
  if ($NextSteps.Count -eq 0) {
    $null = $ReportLines.Add("- no active next-step bullets found in ACTIVE_CONTEXT.md")
  } else {
    foreach ($Step in $NextSteps) {
      $null = $ReportLines.Add("- " + $Step)
    }
  }

  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("## Memory Discipline")
  $null = $ReportLines.Add("")
  $null = $ReportLines.Add("- dream reports are recommendation packets, not silent durable-memory rewrites")
  $null = $ReportLines.Add("- if a recommendation becomes a stable decision, promote only the compact lesson into durable memory")
  $null = $ReportLines.Add("- keep active context aligned with the strongest local-evaluation evidence, not with easier publication work")

  $ReportContent = ($ReportLines -join "`r`n") + "`r`n"
  Write-Utf8NoBomFile -Path $ReportPath -Content $ReportContent
  Write-Utf8NoBomFile -Path $DreamLatestPath -Content $ReportContent

  $NewState = [ordered]@{
    version = "v1"
    last_checked_at = $Now.ToString("o")
    last_status = "completed"
    last_completed_at = $Now.ToString("o")
    last_report_path = $ReportPath.Replace($ProjectRoot + "\", "")
    last_skip_reason = $null
    last_new_president_messages = $NewPresidentMessages.Count
    last_new_local_evaluations = $NewLocalEvaluations.Count
    last_trigger_mode = if ($Force) { "forced" } else { "scheduled" }
    last_lock_status = "released"
    active_memory_lines = $ActiveMemoryMetrics.line_count
    active_memory_bytes = $ActiveMemoryMetrics.byte_count
    durable_memory_lines = $DurableMemoryMetrics.line_count
    durable_memory_bytes = $DurableMemoryMetrics.byte_count
  }
  Write-JsonFile -Path $DreamStatePath -Value $NewState

  Write-Output ("northbridge dream completed: {0}" -f $NewState.last_report_path)
} finally {
  Release-DreamLock
}
