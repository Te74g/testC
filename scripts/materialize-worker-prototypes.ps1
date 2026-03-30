param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$WorkerInboxRoot = Join-Path $ProjectRoot "runtime\inbox\worker"
$ProcessedRoot = Join-Path $ProjectRoot "runtime\inbox\worker-processed"
$FailedRoot = Join-Path $ProjectRoot "runtime\inbox\worker-failed"
$WorkersRoot = Join-Path $ProjectRoot "workers"
$PrototypeRoot = Join-Path $WorkersRoot "prototypes"
$CatalogPath = Join-Path $WorkersRoot "worker-catalog.v1.json"
$TemplatePath = Join-Path $ProjectRoot "templates\local_worker_prompt_template.md"
$LogPath = Join-Path $ProjectRoot "runtime\logs\worker-factory.jsonl"

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

function Append-JsonLine {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [object]$Value
  )

  $Directory = Split-Path -Parent $Path
  if ($Directory) {
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }

  $Encoding = New-Object System.Text.UTF8Encoding($false)
  $Line = ($Value | ConvertTo-Json -Depth 10 -Compress) + "`n"
  [System.IO.File]::AppendAllText($Path, $Line, $Encoding)
}

function Format-Bullets {
  param(
    [Parameter(Mandatory = $true)]
    [object[]]$Items
  )

  return (($Items | ForEach-Object { "- $_" }) -join "`n")
}

function Apply-Replacements {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Template,

    [Parameter(Mandatory = $true)]
    [hashtable]$Map
  )

  $Result = $Template
  foreach ($Key in $Map.Keys) {
    $Token = "{{${Key}}}"
    $Result = $Result.Replace($Token, [string]$Map[$Key])
  }
  return $Result
}

New-Item -ItemType Directory -Force -Path $WorkerInboxRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ProcessedRoot | Out-Null
New-Item -ItemType Directory -Force -Path $FailedRoot | Out-Null
New-Item -ItemType Directory -Force -Path $PrototypeRoot | Out-Null

$Catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Json
$Template = Get-Content $TemplatePath -Raw
$InboxFiles = Get-ChildItem -Path $WorkerInboxRoot -Filter *.json -File | Sort-Object Name

foreach ($InboxFile in $InboxFiles) {
  $Raw = $null
  $Envelope = $null

  try {
    $Raw = Get-Content $InboxFile.FullName -Raw
    $Record = $Raw | ConvertFrom-Json
    $Envelope = $Record.envelope
    if (-not $Envelope) {
      throw "worker inbox item does not contain envelope"
    }

    $WorkerKey = [string]$Envelope.payload.worker_key
    $PrototypeStage = [string]$Envelope.payload.prototype_stage
    if (-not $WorkerKey) {
      throw "worker_key is missing"
    }
    if ($PrototypeStage -ne "prompt_only") {
      throw "unsupported prototype_stage: $PrototypeStage"
    }

    $Definition = $Catalog.workers.$WorkerKey
    if (-not $Definition) {
      throw "unknown worker_key: $WorkerKey"
    }

    $PrototypeDir = Join-Path $PrototypeRoot $WorkerKey
    New-Item -ItemType Directory -Force -Path $PrototypeDir | Out-Null

    $PromptMap = @{
      company_name = [string]$Definition.company_name
      worker_name = [string]$Definition.worker_name
      role = [string]$Definition.role
      mission = [string]$Definition.mission
      allowed_tools = Format-Bullets -Items @($Definition.allowed_tools)
      blocked_tools = Format-Bullets -Items @($Definition.blocked_tools)
      inputs = Format-Bullets -Items @($Definition.inputs)
      outputs = Format-Bullets -Items @($Definition.outputs)
      escalate_to = [string]$Definition.escalate_to
      escalation_conditions = Format-Bullets -Items @($Definition.escalation_conditions)
      budget_mode = [string]$Definition.budget_mode
      quality_checks = Format-Bullets -Items @($Definition.quality_checks)
    }

    $Prompt = Apply-Replacements -Template $Template -Map $PromptMap
    $ProfilePath = Join-Path $PrototypeDir "profile.json"
    $PromptPath = Join-Path $PrototypeDir "prompt.md"

    Write-Utf8NoBomFile -Path $ProfilePath -Content (([ordered]@{
      generated_at = (Get-Date).ToString("o")
      source_command_id = [string]$Envelope.id
      source_worker_key = $WorkerKey
      prototype_stage = $PrototypeStage
      definition = $Definition
    } | ConvertTo-Json -Depth 12) + "`n")
    Write-Utf8NoBomFile -Path $PromptPath -Content ($Prompt.TrimEnd() + "`n")

    Append-JsonLine -Path $LogPath -Value ([ordered]@{
      timestamp = (Get-Date).ToString("o")
      event = "worker_materialized"
      worker_key = $WorkerKey
      source_command_id = [string]$Envelope.id
      profile_path = $ProfilePath
      prompt_path = $PromptPath
    })

    Move-Item -LiteralPath $InboxFile.FullName -Destination (Join-Path $ProcessedRoot $InboxFile.Name) -Force
  } catch {
    Append-JsonLine -Path $LogPath -Value ([ordered]@{
      timestamp = (Get-Date).ToString("o")
      event = "worker_materialization_failed"
      inbox_file = $InboxFile.FullName
      command_id = if ($Envelope) { [string]$Envelope.id } else { "" }
      error = $_.Exception.Message
    })

    Move-Item -LiteralPath $InboxFile.FullName -Destination (Join-Path $FailedRoot $InboxFile.Name) -Force
  }
}

Write-Output "worker materialization pass complete"
