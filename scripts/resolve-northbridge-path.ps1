function Get-NorthbridgeRootCandidates {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot
  )

  $Candidates = New-Object System.Collections.Generic.List[string]

  if ($env:NORTHBRIDGE_HOME) {
    $Candidates.Add([string]$env:NORTHBRIDGE_HOME)
  }

  if ($env:USERPROFILE) {
    $Candidates.Add((Join-Path $env:USERPROFILE ".northbridge"))
  }

  $UserProfile = [Environment]::GetFolderPath("UserProfile")
  if ($UserProfile) {
    $Candidates.Add((Join-Path $UserProfile ".northbridge"))
  }

  if ($ProjectRoot -match '^[A-Za-z]:\\Users\\[^\\]+') {
    $Candidates.Add((Join-Path $matches[0] ".northbridge"))
  }

  return $Candidates | Where-Object { $_ } | Select-Object -Unique
}

function Resolve-NorthbridgeRoot {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [switch]$RequireExisting
  )

  $Candidates = Get-NorthbridgeRootCandidates -ProjectRoot $ProjectRoot
  if ($RequireExisting) {
    return $Candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
  }

  return $Candidates | Select-Object -First 1
}

function Resolve-NorthbridgeControlPath {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [switch]$RequireExisting
  )

  foreach ($Root in (Get-NorthbridgeRootCandidates -ProjectRoot $ProjectRoot)) {
    $ControlPath = Join-Path $Root "northbridge-relay-control.ps1"
    if (-not $RequireExisting -or (Test-Path $ControlPath)) {
      return $ControlPath
    }
  }

  return $null
}
