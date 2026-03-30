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
  [string]$TaskId,
  [string]$BundlePath
)

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PendingRoot = Join-Path $ProjectRoot "runtime\queue\pending"

New-Item -ItemType Directory -Force -Path $PendingRoot | Out-Null

if ($PayloadJson) {
  try {
    $Payload = $PayloadJson | ConvertFrom-Json -AsHashtable
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
  payload = $Payload
}

$Envelope | ConvertTo-Json -Depth 10 | Set-Content -Path $FilePath -Encoding utf8
Write-Output $FilePath
