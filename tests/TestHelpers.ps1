$ErrorActionPreference = 'Stop'

function Get-ProjectRoot {
  return Split-Path -Parent $PSScriptRoot
}

function Get-TestContent {
  param(
    [Parameter(Mandatory = $true)]
    [string]$RelativePath,
    [string]$Encoding = 'utf8'
  )

  $projectRoot = Get-ProjectRoot
  if ($Encoding -eq 'raw') {
    return Get-Content -Raw (Join-Path $projectRoot $RelativePath)
  }

  return Get-Content -Raw -Encoding $Encoding (Join-Path $projectRoot $RelativePath)
}

function New-FailureList {
  return New-Object System.Collections.Generic.List[string]
}

function Expect-Match {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Content,
    [Parameter(Mandatory = $true)]
    [string]$Pattern,
    [System.Collections.Generic.List[string]]$Failures,
    [Parameter(Mandatory = $true)]
    [string]$Message
  )

  if ($Content -notmatch $Pattern) {
    $Failures.Add($Message)
  }
}

function Expect-NotMatch {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Content,
    [Parameter(Mandatory = $true)]
    [string]$Pattern,
    [System.Collections.Generic.List[string]]$Failures,
    [Parameter(Mandatory = $true)]
    [string]$Message
  )

  if ($Content -match $Pattern) {
    $Failures.Add($Message)
  }
}

function Complete-Test {
  param(
    [System.Collections.Generic.List[string]]$Failures,
    [Parameter(Mandatory = $true)]
    [string]$SuccessMessage
  )

  if ($Failures.Count -gt 0) {
    $Failures | ForEach-Object { Write-Host $_ }
    throw "Test failed."
  }

  Write-Host $SuccessMessage
}
