$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Get-Command lua, python -ErrorAction Stop | Out-Null

Push-Location $projectRoot
try {
  & "$PSScriptRoot/verify-strengthening.ps1"
  & "$PSScriptRoot/verify-unique-replacements.ps1"
  & lua "$PSScriptRoot/test-mode-runtime.lua"
  if ($LASTEXITCODE -ne 0) { throw 'Mode runtime regression failed.' }
  & lua "$PSScriptRoot/test-faith-purchases.lua"
  if ($LASTEXITCODE -ne 0) { throw 'Faith purchase regression failed.' }
  & python -B "$PSScriptRoot/test-building-adjacency.py"
  if ($LASTEXITCODE -ne 0) { throw 'Building adjacency database regression failed.' }
  Write-Host 'All Akane regression checks passed.'
} finally {
  Pop-Location
}
