param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$HomeRoot = [Environment]::GetFolderPath("UserProfile")
$NorthbridgeRoot = Join-Path $HomeRoot ".northbridge"
$ManifestPath = Join-Path $NorthbridgeRoot "runtime-manifest.v1.json"
$ControlPath = Join-Path $NorthbridgeRoot "northbridge-relay-control.ps1"
$TrustPath = Join-Path $NorthbridgeRoot "trust-policy.v1.json"
$IdentityPath = Join-Path $NorthbridgeRoot "identity-policy.v1.json"
$TrustExamplePath = Join-Path $ProjectRoot "runtime\\trust-policy.example.v1.json"
$IdentityExamplePath = Join-Path $ProjectRoot "runtime\\identity-policy.example.v1.json"

$CriticalRelativePaths = @(
  "runtime\\relay-bot.js",
  "runtime\\command-registry.v1.json"
)

function Write-Utf8NoBomFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$Content
  )

  $Encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $Encoding)
}

New-Item -ItemType Directory -Force -Path $NorthbridgeRoot | Out-Null

if (-not (Test-Path $TrustPath)) {
  $TrustPolicy = Get-Content $TrustExamplePath -Raw | ConvertFrom-Json
  $TrustPolicy.hmac_secret = [guid]::NewGuid().ToString("N") + [guid]::NewGuid().ToString("N")
  Write-Utf8NoBomFile -Path $TrustPath -Content (($TrustPolicy | ConvertTo-Json -Depth 10) + "`n")
}

if (-not (Test-Path $IdentityPath)) {
  $IdentityPolicy = Get-Content $IdentityExamplePath -Raw | ConvertFrom-Json
  $IdentityPolicy.audit_log_path = Join-Path $NorthbridgeRoot "security-events.jsonl"
  Write-Utf8NoBomFile -Path $IdentityPath -Content (($IdentityPolicy | ConvertTo-Json -Depth 10) + "`n")
}

$CriticalFiles = @()
foreach ($RelativePath in $CriticalRelativePaths) {
  $FullPath = Join-Path $ProjectRoot $RelativePath
  if (-not (Test-Path $FullPath)) {
    throw "Critical file not found: $RelativePath"
  }

  $CriticalFiles += [ordered]@{
    relative_path = $RelativePath
    sha256 = (Get-FileHash -LiteralPath $FullPath -Algorithm SHA256).Hash.ToLowerInvariant()
  }
}

$Manifest = [ordered]@{
  version = "v1"
  created_at = (Get-Date).ToString("o")
  project_root = $ProjectRoot
  trust_policy_path = $TrustPath
  identity_policy_path = $IdentityPath
  critical_files = $CriticalFiles
}

Write-Utf8NoBomFile -Path $ManifestPath -Content (($Manifest | ConvertTo-Json -Depth 10) + "`n")

$ControlScript = @'
param(
  [ValidateSet("Start", "Status", "Stop", "Enqueue")]
  [string]$Action = "Status",

  [string]$Command,
  [string]$Sender,
  [string]$Receiver,
  [string]$Reason,

  [ValidateSet("low", "normal", "high")]
  [string]$Priority = "normal",

  [ValidateSet("not_required", "required", "approved")]
  [string]$ApprovalStatus = "not_required",

  [string]$PayloadJson = "",
  [string]$MemoryTarget,
  [string]$MemoryOperation,
  [string]$TargetCompany,
  [string]$Topic,
  [string]$DesiredOutput,
  [string]$WorkerKey,
  [string]$PrototypeStage,
  [string]$TaskId,
  [string]$BundlePath
)

$NorthbridgeRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ManifestPath = Join-Path $NorthbridgeRoot "runtime-manifest.v1.json"

function Read-JsonFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  return Get-Content $Path -Raw | ConvertFrom-Json
}

function Write-Utf8NoBomJson {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [object]$Value
  )

  $Json = ($Value | ConvertTo-Json -Depth 10) + "`n"
  $Encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Json, $Encoding)
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
  $Existing = ""
  if (Test-Path $Path) {
    $Existing = [System.IO.File]::ReadAllText($Path)
  }
  [System.IO.File]::WriteAllText($Path, $Existing + $Line + "`n", $Encoding)
}

function Normalize-Identity {
  param(
    [string]$Value
  )

  if (-not $Value) {
    return ""
  }

  return $Value.Trim().ToLowerInvariant()
}

function Get-EnvelopeSignature {
  param(
    [Parameter(Mandatory = $true)]
    [hashtable]$Envelope,

    [Parameter(Mandatory = $true)]
    [string]$Secret
  )

  $Basis = [ordered]@{
    id = $Envelope.id
    command = $Envelope.command
    sender = $Envelope.sender
    receiver = $Envelope.receiver
    reason = $Envelope.reason
    priority = $Envelope.priority
    created_at = $Envelope.created_at
    approval_status = $Envelope.approval_status
    payload = $Envelope.payload
  }

  $BasisJson = $Basis | ConvertTo-Json -Depth 10 -Compress
  $SecretBytes = [System.Text.Encoding]::UTF8.GetBytes($Secret)
  $DataBytes = [System.Text.Encoding]::UTF8.GetBytes($BasisJson)
  $Hmac = New-Object System.Security.Cryptography.HMACSHA256
  $Hmac.Key = $SecretBytes

  try {
    $SignatureBytes = $Hmac.ComputeHash($DataBytes)
  } finally {
    $Hmac.Dispose()
  }

  return ([System.BitConverter]::ToString($SignatureBytes)).Replace("-", "").ToLowerInvariant()
}

function Get-CurrentIdentitySnapshot {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot
  )

  $GitUserName = ""
  $GitUserEmail = ""

  try {
    $GitUserName = (& git -C $ProjectRoot config user.name 2>$null | Select-Object -First 1)
  } catch {
    $GitUserName = ""
  }

  try {
    $GitUserEmail = (& git -C $ProjectRoot config user.email 2>$null | Select-Object -First 1)
  } catch {
    $GitUserEmail = ""
  }

  return [pscustomobject]@{
    os_user_name = $env:USERNAME
    git_user_name = $GitUserName
    git_user_email = $GitUserEmail
  }
}

function Write-SecurityEvent {
  param(
    [Parameter(Mandatory = $true)]
    [string]$AuditPath,

    [Parameter(Mandatory = $true)]
    [string]$EventType,

    [Parameter(Mandatory = $true)]
    [object]$Details
  )

  $Record = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    event = $EventType
    details = $Details
  }

  Append-Utf8NoBomLine -Path $AuditPath -Line ($Record | ConvertTo-Json -Depth 10 -Compress)
}

function Assert-IdentityAllowed {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Manifest
  )

  if (-not $Manifest.identity_policy_path) {
    return $null
  }

  if (-not (Test-Path $Manifest.identity_policy_path)) {
    return $null
  }

  $IdentityPolicy = Read-JsonFile -Path $Manifest.identity_policy_path
  $Identity = Get-CurrentIdentitySnapshot -ProjectRoot $Manifest.project_root
  $Matches = @()

  $BlockedGitUsers = @($IdentityPolicy.blocked_git_usernames) | ForEach-Object { Normalize-Identity $_ } | Where-Object { $_ }
  $BlockedGitEmails = @($IdentityPolicy.blocked_git_emails) | ForEach-Object { Normalize-Identity $_ } | Where-Object { $_ }
  $BlockedOsUsers = @($IdentityPolicy.blocked_os_usernames) | ForEach-Object { Normalize-Identity $_ } | Where-Object { $_ }

  $NormalizedGitUser = Normalize-Identity $Identity.git_user_name
  $NormalizedGitEmail = Normalize-Identity $Identity.git_user_email
  $NormalizedOsUser = Normalize-Identity $Identity.os_user_name

  if ($NormalizedGitUser -and ($BlockedGitUsers -contains $NormalizedGitUser)) {
    $Matches += "git_user_name"
  }
  if ($NormalizedGitEmail -and ($BlockedGitEmails -contains $NormalizedGitEmail)) {
    $Matches += "git_user_email"
  }
  if ($NormalizedOsUser -and ($BlockedOsUsers -contains $NormalizedOsUser)) {
    $Matches += "os_user_name"
  }

  if ($Matches.Count -gt 0) {
    $AuditPath = if ($IdentityPolicy.audit_log_path) { [string]$IdentityPolicy.audit_log_path } else { Join-Path $NorthbridgeRoot "security-events.jsonl" }

    Write-SecurityEvent -AuditPath $AuditPath -EventType "blocked_identity_detected" -Details ([ordered]@{
      project_root = $Manifest.project_root
      matches = $Matches
      identity = $Identity
    })

    foreach ($Line in @($IdentityPolicy.message_lines)) {
      if ($Line) {
        Write-Host $Line
      }
    }

    throw "guarded control denied for blocked identity"
  }

  return [pscustomobject]@{
    Policy = $IdentityPolicy
    Identity = $Identity
  }
}

function Assert-GuardedEnvironment {
  if (-not (Test-Path $ManifestPath)) {
    throw "runtime manifest not found at $ManifestPath"
  }

  $Manifest = Read-JsonFile -Path $ManifestPath
  if (-not $Manifest.project_root) {
    throw "runtime manifest is missing project_root"
  }
  if (-not (Test-Path $Manifest.project_root)) {
    throw "project_root does not exist: $($Manifest.project_root)"
  }
  if (-not (Test-Path $Manifest.trust_policy_path)) {
    throw "trust policy not found: $($Manifest.trust_policy_path)"
  }

  foreach ($File in $Manifest.critical_files) {
    $FullPath = Join-Path $Manifest.project_root $File.relative_path
    if (-not (Test-Path $FullPath)) {
      throw "critical file missing: $($File.relative_path)"
    }

    $ActualHash = (Get-FileHash -LiteralPath $FullPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $ExpectedHash = ([string]$File.sha256).ToLowerInvariant()

    if ($ActualHash -ne $ExpectedHash) {
      throw "integrity check failed for $($File.relative_path)"
    }
  }

  $TrustPolicy = Read-JsonFile -Path $Manifest.trust_policy_path
  if (-not $TrustPolicy.require_signature) {
    throw "guarded control refuses to run without require_signature=true"
  }
  if (-not $TrustPolicy.hmac_secret) {
    throw "guarded control refuses to run without hmac_secret"
  }

  $RegistryPath = Join-Path $Manifest.project_root "runtime\\command-registry.v1.json"
  $Registry = Read-JsonFile -Path $RegistryPath
  $IdentityGuard = Assert-IdentityAllowed -Manifest $Manifest

  return [pscustomobject]@{
    Manifest = $Manifest
    TrustPolicy = $TrustPolicy
    Registry = $Registry
    IdentityGuard = $IdentityGuard
  }
}

function Build-Payload {
  param(
    [Parameter(Mandatory = $true)]
    [string]$CommandName
  )

  if ($PayloadJson) {
    try {
      return $PayloadJson | ConvertFrom-Json
    } catch {
      throw "PayloadJson must be valid JSON"
    }
  }

  $Payload = [ordered]@{}

  switch ($CommandName) {
    "nc.memory" {
      if (-not $MemoryTarget -or -not $MemoryOperation) {
        throw "nc.memory requires -MemoryTarget and -MemoryOperation when -PayloadJson is not supplied"
      }
      $Payload.memory_target = $MemoryTarget
      $Payload.operation = $MemoryOperation
    }
    "nc.call" {
      if (-not $TargetCompany -or -not $Topic -or -not $DesiredOutput) {
        throw "nc.call requires -TargetCompany, -Topic, and -DesiredOutput when -PayloadJson is not supplied"
      }
      $Payload.target_company = $TargetCompany
      $Payload.topic = $Topic
      $Payload.desired_output = $DesiredOutput
    }
    "nc.resume" {
      if (-not $TaskId -or -not $BundlePath) {
        throw "nc.resume requires -TaskId and -BundlePath when -PayloadJson is not supplied"
      }
      $Payload.task_id = $TaskId
      $Payload.bundle_path = $BundlePath
    }
    "nc.worker.seed" {
      if (-not $WorkerKey) {
        throw "nc.worker.seed requires -WorkerKey when -PayloadJson is not supplied"
      }
      if (-not $PrototypeStage) {
        $PrototypeStage = "prompt_only"
      }
      $Payload.worker_key = $WorkerKey
      $Payload.prototype_stage = $PrototypeStage
    }
    default {
      throw "Unsupported command: $CommandName"
    }
  }

  return [pscustomobject]$Payload
}

function Start-RelayBot {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Guard
  )

  $ProjectRoot = $Guard.Manifest.project_root
  $RuntimeRoot = Join-Path $ProjectRoot "runtime"
  $LogsRoot = Join-Path $RuntimeRoot "logs"
  $StateRoot = Join-Path $RuntimeRoot "state"
  $PidPath = Join-Path $StateRoot "relay-bot.pid"
  $BotPath = Join-Path $RuntimeRoot "relay-bot.js"
  $NodePath = (Get-Command node -ErrorAction Stop).Source

  New-Item -ItemType Directory -Force -Path $LogsRoot | Out-Null
  New-Item -ItemType Directory -Force -Path $StateRoot | Out-Null

  if (Test-Path $PidPath) {
    $ExistingPid = Get-Content $PidPath -ErrorAction SilentlyContinue
    if ($ExistingPid) {
      $ExistingProcess = Get-Process -Id $ExistingPid -ErrorAction SilentlyContinue
      if ($ExistingProcess) {
        Write-Output "relay-bot is already running with PID $ExistingPid"
        return
      }
    }
    Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
  }

  $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
  $StartInfo.FileName = $NodePath
  $StartInfo.Arguments = ('"{0}"' -f $BotPath)
  $StartInfo.WorkingDirectory = $ProjectRoot
  $StartInfo.UseShellExecute = $false
  $StartInfo.CreateNoWindow = $true
  $null = $StartInfo.EnvironmentVariables["NORTHBRIDGE_TRUST_POLICY_PATH"] = [string]$Guard.Manifest.trust_policy_path

  $Process = New-Object System.Diagnostics.Process
  $Process.StartInfo = $StartInfo
  $null = $Process.Start()

  Set-Content -Path $PidPath -Value $Process.Id -Encoding ascii
  Start-Sleep -Milliseconds 800

  $RunningProcess = Get-Process -Id $Process.Id -ErrorAction SilentlyContinue
  if (-not $RunningProcess) {
    throw "relay-bot failed to start"
  }

  Write-Output "guarded relay-bot started with PID $($Process.Id)"
}

function Get-RelayStatus {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Guard
  )

  $StatusPath = Join-Path $Guard.Manifest.project_root "runtime\\state\\relay-bot.status.json"
  if (-not (Test-Path $StatusPath)) {
    Write-Output "relay-bot status file not found"
    return
  }

  Get-Content $StatusPath -Raw
}

function Stop-RelayBot {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Guard
  )

  $PidPath = Join-Path $Guard.Manifest.project_root "runtime\\state\\relay-bot.pid"
  if (-not (Test-Path $PidPath)) {
    Write-Output "relay-bot is not running"
    return
  }

  $StoredPid = Get-Content $PidPath -ErrorAction SilentlyContinue
  if (-not $StoredPid) {
    Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
    Write-Output "relay-bot pid file was empty"
    return
  }

  $RelayProcess = Get-Process -Id $StoredPid -ErrorAction SilentlyContinue
  if (-not $RelayProcess) {
    Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
    Write-Output "relay-bot process was not running"
    return
  }

  Stop-Process -Id $StoredPid -Force
  Remove-Item $PidPath -Force -ErrorAction SilentlyContinue
  Write-Output "relay-bot stopped"
}

function Enqueue-RelayCommand {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Guard
  )

  if (-not $Command -or -not $Sender -or -not $Receiver -or -not $Reason) {
    throw "Enqueue requires -Command, -Sender, -Receiver, and -Reason"
  }

  $CommandSpec = $Guard.Registry.commands.$Command
  if (-not $CommandSpec) {
    throw "Unknown command in guarded control: $Command"
  }

  $Payload = Build-Payload -CommandName $Command

  $Envelope = [ordered]@{
    id = [guid]::NewGuid().ToString("N")
    command = $Command
    sender = $Sender
    receiver = $Receiver
    reason = $Reason
    priority = $Priority
    created_at = (Get-Date).ToString("o")
    approval_status = $ApprovalStatus
    signature = ""
    payload = $Payload
  }

  $Envelope.signature = Get-EnvelopeSignature -Envelope $Envelope -Secret ([string]$Guard.TrustPolicy.hmac_secret)

  $PendingRoot = Join-Path $Guard.Manifest.project_root "runtime\\queue\\pending"
  New-Item -ItemType Directory -Force -Path $PendingRoot | Out-Null

  $FileStamp = (Get-Date).ToString("yyyyMMdd-HHmmssfff")
  $FilePath = Join-Path $PendingRoot ("{0}-{1}.json" -f $FileStamp, $Envelope.id)
  Write-Utf8NoBomJson -Path $FilePath -Value $Envelope

  Write-Output $FilePath
}

$Guard = Assert-GuardedEnvironment

switch ($Action) {
  "Start" { Start-RelayBot -Guard $Guard }
  "Status" { Get-RelayStatus -Guard $Guard }
  "Stop" { Stop-RelayBot -Guard $Guard }
  "Enqueue" { Enqueue-RelayCommand -Guard $Guard }
  default { throw "Unsupported action: $Action" }
}
'@

Write-Utf8NoBomFile -Path $ControlPath -Content ($ControlScript + "`n")

Write-Output "runtime guard installed"
Write-Output "manifest: $ManifestPath"
Write-Output "control: $ControlPath"
