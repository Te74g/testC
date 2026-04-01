param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$StatusPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.status.json"
$LockPath = Join-Path $ProjectRoot "runtime\state\long-run-supervisor.tick.lock"
$TaskName = "NorthbridgeSupervisorTick"

if (-not (Test-Path $StatusPath)) {
  Write-Output "status=stopped"
  exit 0
}

$StatusJson = Get-Content $StatusPath -Raw | ConvertFrom-Json
$Task = $null
$TaskLookupResult = "not_checked"
$TaskLookupErrorType = ""
if ($null -ne (Get-Command Get-ScheduledTask -ErrorAction SilentlyContinue)) {
  try {
    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
    if ($Task) {
      $TaskLookupResult = "available"
    } else {
      $TaskLookupResult = "missing"
    }
  } catch {
    $TaskLookupResult = "inaccessible"
    $TaskLookupErrorType = if ($_.Exception) { [string]$_.Exception.GetType().FullName } else { "UnknownException" }
  }
}

$Status = "stopped"
$Now = [DateTimeOffset]::Now
$LastHeartbeatAt = $null
try {
  if ($StatusJson.last_heartbeat) {
    $LastHeartbeatAt = [DateTimeOffset]::Parse($StatusJson.last_heartbeat)
  }
} catch {
}

$IntervalMinutes = 5
if ($StatusJson.interval_minutes) {
  $IntervalMinutes = [int]$StatusJson.interval_minutes
}
$StaleAfterMinutes = [Math]::Max(15, $IntervalMinutes * 3)

if (Test-Path $LockPath) {
  $Status = "running"
} elseif ($Task) {
  if ($Task.State -eq "Ready" -or $Task.State -eq "Running") {
    $Status = "scheduled"
    if ($LastHeartbeatAt -and (($Now - $LastHeartbeatAt).TotalMinutes -gt $StaleAfterMinutes)) {
      $Status = "stale"
      $StatusJson.state = "stale"
      $StatusJson.last_result = "stale_status"
    }
  } else {
    if ($StatusJson.end_at) {
      try {
        $EndAt = [DateTimeOffset]::Parse($StatusJson.end_at)
        if ($Now -ge $EndAt) {
          $Status = "completed"
          $StatusJson.state = "completed"
          if (-not $StatusJson.last_result -or $StatusJson.last_result -eq "scheduled") {
            $StatusJson.last_result = "completed"
          }
        } else {
          $Status = "stopped"
        }
      } catch {
        $Status = "stopped"
      }
    } else {
      $Status = "stopped"
    }
  }
} elseif ($TaskLookupResult -eq "inaccessible") {
  if ($LastHeartbeatAt -and (($Now - $LastHeartbeatAt).TotalMinutes -le $StaleAfterMinutes)) {
    $Status = "scheduled"
  } else {
    $Status = "stale"
    $StatusJson.state = "stale"
    $StatusJson.last_result = "stale_status"
  }
} else {
  $Status = "stopped"
}

$StatusJson.state = $Status
$StatusJson | Add-Member -NotePropertyName checked_at -NotePropertyValue ([DateTimeOffset]::Now.ToString("o")) -Force
$StatusJson | Add-Member -NotePropertyName scheduled_task_lookup_result -NotePropertyValue $TaskLookupResult -Force
$StatusJson | Add-Member -NotePropertyName scheduled_task_lookup_error_type -NotePropertyValue $TaskLookupErrorType -Force
if ($Task) {
  $StatusJson | Add-Member -NotePropertyName scheduled_task_name -NotePropertyValue $TaskName -Force
  $StatusJson | Add-Member -NotePropertyName scheduled_task_state -NotePropertyValue ([string]$Task.State) -Force
} else {
  $StatusJson | Add-Member -NotePropertyName scheduled_task_name -NotePropertyValue $TaskName -Force
  $StatusJson | Add-Member -NotePropertyName scheduled_task_state -NotePropertyValue $TaskLookupResult -Force
}
$StatusJson | ConvertTo-Json -Depth 10 | Set-Content -Path $StatusPath -Encoding UTF8

Write-Output "status=$Status"
if ($Task) {
  Write-Output "task=$TaskName"
  Write-Output "task_state=$($Task.State)"
}
$StatusJson | ConvertTo-Json -Depth 10
