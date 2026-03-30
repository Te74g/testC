param()

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$HomeRoot = [Environment]::GetFolderPath("UserProfile")
$NorthbridgeRoot = Join-Path $HomeRoot ".northbridge"
$TrustPath = Join-Path $NorthbridgeRoot "trust-policy.v1.json"
$ExamplePath = Join-Path $ProjectRoot "runtime\\trust-policy.example.v1.json"

New-Item -ItemType Directory -Force -Path $NorthbridgeRoot | Out-Null

if (Test-Path $TrustPath) {
  Write-Output "trust policy already exists at $TrustPath"
  exit 0
}

$Policy = Get-Content $ExamplePath -Raw | ConvertFrom-Json
$Policy.hmac_secret = [guid]::NewGuid().ToString("N") + [guid]::NewGuid().ToString("N")
$Policy | ConvertTo-Json -Depth 10 | Set-Content -Path $TrustPath -Encoding utf8

Write-Output "trust policy created at $TrustPath"
