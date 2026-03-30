param(
  [Parameter(Mandatory = $true)]
  [string]$Command,

  [Parameter(Mandatory = $true)]
  [string]$Sender,

  [Parameter(Mandatory = $true)]
  [string]$Receiver,

  [Parameter(Mandatory = $true)]
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

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PendingRoot = Join-Path $ProjectRoot "runtime\queue\pending"
$TrustCandidates = @()

if ($env:NORTHBRIDGE_TRUST_POLICY_PATH) {
  $TrustCandidates += $env:NORTHBRIDGE_TRUST_POLICY_PATH
}

$TrustCandidates += (Join-Path ([Environment]::GetFolderPath("UserProfile")) ".northbridge\trust-policy.v1.json")

if ($ProjectRoot -match '^[A-Za-z]:\\Users\\[^\\]+') {
  $OwnerHome = $matches[0]
  $TrustCandidates += (Join-Path $OwnerHome ".northbridge\trust-policy.v1.json")
}

$TrustPath = $TrustCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

New-Item -ItemType Directory -Force -Path $PendingRoot | Out-Null

if ($PayloadJson) {
  try {
    $Payload = $PayloadJson | ConvertFrom-Json
  } catch {
    throw "PayloadJson must be valid JSON"
  }
} else {
  $Payload = [ordered]@{}

  switch ($Command) {
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
      throw "Unsupported command: $Command"
    }
  }
}

$Id = [guid]::NewGuid().ToString("N")
$CreatedAt = (Get-Date).ToString("o")
$FileStamp = (Get-Date).ToString("yyyyMMdd-HHmmssfff")
$FileName = "{0}-{1}.json" -f $FileStamp, $Id
$FilePath = Join-Path $PendingRoot $FileName

$Envelope = [ordered]@{
  id = $Id
  command = $Command
  sender = $Sender
  receiver = $Receiver
  reason = $Reason
  priority = $Priority
  created_at = $CreatedAt
  approval_status = $ApprovalStatus
  signature = ""
  payload = $Payload
}

if (Test-Path $TrustPath) {
  $TrustPolicy = Get-Content $TrustPath -Raw | ConvertFrom-Json
  if ($TrustPolicy.require_signature -and $TrustPolicy.hmac_secret) {
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
    $SecretBytes = [System.Text.Encoding]::UTF8.GetBytes([string]$TrustPolicy.hmac_secret)
    $DataBytes = [System.Text.Encoding]::UTF8.GetBytes($BasisJson)
    $Hmac = New-Object System.Security.Cryptography.HMACSHA256
    $Hmac.Key = $SecretBytes
    try {
      $SignatureBytes = $Hmac.ComputeHash($DataBytes)
    } finally {
      $Hmac.Dispose()
    }
    $Envelope.signature = ([System.BitConverter]::ToString($SignatureBytes)).Replace("-", "").ToLowerInvariant()
  }
}

$Envelope | ConvertTo-Json -Depth 10 | Set-Content -Path $FilePath -Encoding utf8
Write-Output $FilePath
