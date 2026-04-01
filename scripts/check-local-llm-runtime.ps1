param()

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$BindingsPath = Join-Path $ProjectRoot "runtime\config\local-llm-bindings.v1.json"
$RuntimeConfigPath = Join-Path $ProjectRoot "runtime\config\local-llm-runtime.v1.json"
$StatePath = Join-Path $ProjectRoot "runtime\state\local-llm-runtime.state.json"

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

function Test-OllamaEndpoint {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Url,

    [int]$TimeoutSec = 5
  )

  $Response = Invoke-RestMethod -Method Get -Uri $Url -TimeoutSec $TimeoutSec
  $Models = @()
  if ($Response.models) {
    $Models = @($Response.models | ForEach-Object { [string]$_.name })
  }

  return $Models
}

function Resolve-OllamaCliSource {
  param(
    $RuntimeConfig
  )

  $CliCommand = Get-Command ollama -ErrorAction SilentlyContinue
  if ($null -ne $CliCommand) {
    return [ordered]@{
      available = $true
      source = [string]$CliCommand.Source
      resolution = "path"
    }
  }

  $Candidates = @()
  if ($RuntimeConfig -and $RuntimeConfig.known_cli_candidates) {
    $Candidates = @($RuntimeConfig.known_cli_candidates | ForEach-Object { [string]$_ })
  }

  foreach ($Candidate in $Candidates) {
    if ($Candidate -and (Test-Path $Candidate)) {
      return [ordered]@{
        available = $true
        source = $Candidate
        resolution = "configured_candidate"
      }
    }
  }

  return [ordered]@{
    available = $false
    source = ""
    resolution = "not_found"
  }
}

function Invoke-OllamaAutoRecovery {
  param(
    [Parameter(Mandatory = $true)]
    [hashtable]$Record,

    [Parameter(Mandatory = $true)]
    [string]$TagsUrl,

    [Parameter(Mandatory = $true)]
    [string]$CliSource,

    $RuntimeConfig
  )

  $WaitSeconds = 15
  $PollSeconds = 2
  $ServeArgs = @("serve")

  if ($RuntimeConfig) {
    if ($null -ne $RuntimeConfig.recovery_wait_seconds) {
      $WaitSeconds = [Math]::Max(3, [int]$RuntimeConfig.recovery_wait_seconds)
    }
    if ($null -ne $RuntimeConfig.recovery_poll_interval_seconds) {
      $PollSeconds = [Math]::Max(1, [int]$RuntimeConfig.recovery_poll_interval_seconds)
    }
    if ($RuntimeConfig.serve_arguments) {
      $ServeArgs = @($RuntimeConfig.serve_arguments | ForEach-Object { [string]$_ })
    }
  }

  $Record.recovery_attempted = $true
  $Record.recovery_method = "ollama_serve"
  $Record.recovery_source = $CliSource
  $Record.recovery_started_at = (Get-Date).ToString("o")
  $Record.recovery_wait_seconds = $WaitSeconds
  $Record.recovery_poll_interval_seconds = $PollSeconds

  try {
    $Process = Start-Process -FilePath $CliSource -ArgumentList $ServeArgs -WindowStyle Hidden -PassThru
    if ($Process) {
      $Record.recovery_started_process_id = [int]$Process.Id
    }
  } catch {
    $Record.recovery_succeeded = $false
    $Record.recovery_detail = "Failed to launch Ollama serve."
    $Record.recovery_error_type = if ($_.Exception) { [string]$_.Exception.GetType().FullName } else { "UnknownException" }
    return $null
  }

  $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
  while ($Stopwatch.Elapsed.TotalSeconds -lt $WaitSeconds) {
    Start-Sleep -Seconds $PollSeconds

    try {
      $Models = Test-OllamaEndpoint -Url $TagsUrl -TimeoutSec 5
      $Stopwatch.Stop()
      $Record.recovery_succeeded = $true
      $Record.recovery_completed_at = (Get-Date).ToString("o")
      $Record.recovery_duration_seconds = [Math]::Round($Stopwatch.Elapsed.TotalSeconds, 2)
      $Record.recovery_detail = "Local LLM runtime was auto-recovered by launching Ollama serve."
      return $Models
    } catch {
      continue
    }
  }

  $Stopwatch.Stop()
  $Record.recovery_succeeded = $false
  $Record.recovery_completed_at = (Get-Date).ToString("o")
  $Record.recovery_duration_seconds = [Math]::Round($Stopwatch.Elapsed.TotalSeconds, 2)
  $Record.recovery_detail = "Ollama auto-recovery was attempted but the endpoint did not become reachable in time."
  return $null
}

if (-not (Test-Path $BindingsPath)) {
  throw "local LLM bindings not found at $BindingsPath"
}

$Bindings = Get-Content $BindingsPath -Raw | ConvertFrom-Json
$RuntimeConfig = $null
if (Test-Path $RuntimeConfigPath) {
  $RuntimeConfig = Get-Content $RuntimeConfigPath -Raw | ConvertFrom-Json
}

$BaseUrl = [string]$Bindings.base_url
$Provider = [string]$Bindings.provider
$DefaultModel = [string]$Bindings.default_model
$CliResolution = Resolve-OllamaCliSource -RuntimeConfig $RuntimeConfig
$CliAvailable = [bool]$CliResolution.available
$CliSource = [string]$CliResolution.source
$RecoveryEnabled = $false
if ($RuntimeConfig -and $null -ne $RuntimeConfig.auto_recovery_enabled) {
  $RecoveryEnabled = [bool]$RuntimeConfig.auto_recovery_enabled
}

$Record = [ordered]@{
  checked_at = (Get-Date).ToString("o")
  provider = $Provider
  base_url = $BaseUrl
  default_model = $DefaultModel
  runtime_config_loaded = $null -ne $RuntimeConfig
  cli_available = $CliAvailable
  cli_source = $CliSource
  cli_resolution = [string]$CliResolution.resolution
  auto_recovery_enabled = $RecoveryEnabled
  reachable = $false
  model_available = $false
  status = "unknown"
  available_models = @()
  detail = ""
  error_type = ""
  ollama_process_count = (Get-Process -Name "ollama" -ErrorAction SilentlyContinue | Measure-Object).Count
  recovery_attempted = $false
  recovery_method = ""
  recovery_source = ""
  recovery_started_at = ""
  recovery_started_process_id = 0
  recovery_wait_seconds = 0
  recovery_poll_interval_seconds = 0
  recovery_succeeded = $false
  recovery_completed_at = ""
  recovery_duration_seconds = 0
  recovery_detail = ""
  recovery_error_type = ""
}

if ($Provider -ne "ollama") {
  $Record.status = "unsupported_provider"
  $Record.detail = "Only Ollama health checks are currently implemented."
  Write-Utf8NoBomFile -Path $StatePath -Content (($Record | ConvertTo-Json -Depth 10) + "`n")
  Write-Output "local LLM runtime health written"
  return
}

$TagsUrl = ("{0}/api/tags" -f $BaseUrl.TrimEnd("/"))

try {
  $Models = Test-OllamaEndpoint -Url $TagsUrl -TimeoutSec 5

  $Record.reachable = $true
  $Record.available_models = $Models
  $Record.model_available = $Models -contains $DefaultModel
  if ($Record.model_available) {
    $Record.status = "ready"
    $Record.detail = "Local LLM runtime is reachable and the configured model is present."
  } else {
    $Record.status = "reachable_missing_model"
    $Record.detail = "Local LLM runtime is reachable but the configured default model is missing."
  }
} catch {
  $Record.error_type = if ($_.Exception) { [string]$_.Exception.GetType().FullName } else { "UnknownException" }

  if ($RecoveryEnabled -and $CliAvailable) {
    $RecoveredModels = Invoke-OllamaAutoRecovery -Record $Record -TagsUrl $TagsUrl -CliSource $CliSource -RuntimeConfig $RuntimeConfig
    if ($null -ne $RecoveredModels) {
      $Record.reachable = $true
      $Record.available_models = $RecoveredModels
      $Record.model_available = $RecoveredModels -contains $DefaultModel
      if ($Record.model_available) {
        $Record.status = "ready"
        $Record.detail = "Local LLM runtime was unreachable but auto-recovered successfully and the configured model is present."
      } else {
        $Record.status = "reachable_missing_model"
        $Record.detail = "Local LLM runtime was auto-recovered successfully but the configured default model is missing."
      }
    } else {
      $Record.status = "unreachable_recovery_failed"
      $Record.detail = "Unable to reach local LLM endpoint and auto-recovery failed."
    }
  } else {
    $Record.status = "unreachable"
    $Record.detail = "Unable to reach local LLM endpoint."
    if (-not $RecoveryEnabled) {
      $Record.recovery_detail = "Auto-recovery is disabled."
    } elseif (-not $CliAvailable) {
      $Record.recovery_detail = "Auto-recovery is enabled but no Ollama CLI source was found."
    }
  }
}

Write-Utf8NoBomFile -Path $StatePath -Content (($Record | ConvertTo-Json -Depth 10) + "`n")
Write-Output "local LLM runtime health written"
