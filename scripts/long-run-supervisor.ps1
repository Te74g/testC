param(
  [int]$Hours = 10,
  [int]$IntervalMinutes = 15
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$StateRoot = Join-Path $ProjectRoot "runtime\state"
$StatusPath = Join-Path $StateRoot "long-run-supervisor.status.json"
$PidPath = Join-Path $StateRoot "long-run-supervisor.pid"
$LogPath = Join-Path $ProjectRoot "runtime\logs\long-run-supervisor.jsonl"
$EndAt = (Get-Date).AddHours($Hours)

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

function Append-Utf8NoBomLine {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$Line
  )

  $Directory = Split-Path -Parent $Path
  if ($Directory) {
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }

  $Encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::AppendAllText($Path, $Line + "`n", $Encoding)
}

function Write-Status {
  param(
    [string]$State,
    [int]$CycleCount,
    [string]$LastCycleAt,
    [string]$LastResult
  )

  $Status = [ordered]@{
    pid = $PID
    state = $State
    started_at = $StartedAt
    end_at = $EndAt.ToString("o")
    interval_minutes = $IntervalMinutes
    cycle_count = $CycleCount
    last_cycle_at = $LastCycleAt
    last_result = $LastResult
    last_heartbeat = (Get-Date).ToString("o")
  }

  Write-Utf8NoBomFile -Path $StatusPath -Content (($Status | ConvertTo-Json -Depth 10) + "`n")
}

function Log-Event {
  param(
    [string]$Event,
    [object]$Details
  )

  $Record = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    event = $Event
    details = $Details
  }

  Append-Utf8NoBomLine -Path $LogPath -Line ($Record | ConvertTo-Json -Depth 10 -Compress)
}

function Invoke-CheckedScript {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptName
  )

  $Output = powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot $ScriptName)
  if ($LASTEXITCODE -ne 0) {
    throw "$ScriptName failed with exit code $LASTEXITCODE"
  }

  return @($Output)
}

$StartedAt = (Get-Date).ToString("o")
New-Item -ItemType Directory -Force -Path $StateRoot | Out-Null
Set-Content -Path $PidPath -Value $PID -Encoding ascii

$CycleCount = 0
Write-Status -State "running" -CycleCount $CycleCount -LastCycleAt "" -LastResult "starting"
Log-Event -Event "supervisor_started" -Details ([ordered]@{
  hours = $Hours
  interval_minutes = $IntervalMinutes
  end_at = $EndAt.ToString("o")
})

try {
  while ((Get-Date) -lt $EndAt) {
    $CycleCount += 1
    $CycleTime = (Get-Date).ToString("o")

    try {
      $ContinueOutput = Invoke-CheckedScript -ScriptName "continue-bot-work.ps1"
      $HeartbeatOutput = Invoke-CheckedScript -ScriptName "write-bot-work-heartbeat.ps1"

      Log-Event -Event "supervisor_cycle_ok" -Details ([ordered]@{
        cycle = $CycleCount
        cycle_at = $CycleTime
        continue_output = @($ContinueOutput)
        heartbeat_output = @($HeartbeatOutput)
      })

      Write-Status -State "running" -CycleCount $CycleCount -LastCycleAt $CycleTime -LastResult "ok"
    } catch {
      Log-Event -Event "supervisor_cycle_failed" -Details ([ordered]@{
        cycle = $CycleCount
        cycle_at = $CycleTime
        error = $_.Exception.Message
      })

      Write-Status -State "running" -CycleCount $CycleCount -LastCycleAt $CycleTime -LastResult "failed"
    }

    $Now = Get-Date
    if ($Now -ge $EndAt) {
      break
    }

    $Remaining = $EndAt - $Now
    $SleepSeconds = [Math]::Min($IntervalMinutes * 60, [Math]::Max(1, [int][Math]::Floor($Remaining.TotalSeconds)))
    Start-Sleep -Seconds $SleepSeconds
  }

  Write-Status -State "completed" -CycleCount $CycleCount -LastCycleAt (Get-Date).ToString("o") -LastResult "completed"
  Log-Event -Event "supervisor_completed" -Details ([ordered]@{
    cycle_count = $CycleCount
  })
} finally {
  Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
}
