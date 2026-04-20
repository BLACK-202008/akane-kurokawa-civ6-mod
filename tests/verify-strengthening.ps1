$ErrorActionPreference = 'Stop'

$testScripts = @(
  'verify-adjacency-data.ps1',
  'verify-modifier-scopes.ps1',
  'verify-building-chains.ps1',
  'verify-stage-system.ps1',
  'verify-text-and-docs.ps1'
)

$failed = New-Object System.Collections.Generic.List[string]

foreach ($scriptName in $testScripts) {
  $scriptPath = Join-Path $PSScriptRoot $scriptName
  try {
    & $scriptPath
  } catch {
    $failed.Add($scriptName)
  }
}

if ($failed.Count -gt 0) {
  Write-Host 'Verification suite failed:'
  $failed | ForEach-Object { Write-Host "- $_" }
  exit 1
}

Write-Host 'Strengthening verification passed.'
