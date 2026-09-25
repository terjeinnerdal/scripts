<#
.SYNOPSIS
  Creates a new empty file at the specified path if it does not already exist.

.DESCRIPTION
  Safely creates a new file at the specified path. If parent directories do not exist,
  they are created automatically. Supports -WhatIf and -Confirm.

.PARAMETER Path
  The file path to create. This parameter is mandatory.

.EXAMPLE
  .\CreateFile.ps1 -Path "C:\Temp\newfile.txt"
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The file path to create.")]
    [string]$Path
)

if (Test-Path -LiteralPath $Path) {
    Write-Warning "File '$Path' already exists."
    return
}

$parentDir = Split-Path -Path $Path -Parent
if ($parentDir -and (-not (Test-Path -LiteralPath $parentDir -PathType Container))) {
    if ($PSCmdlet.ShouldProcess($parentDir, "Create Directory")) {
        New-Item -ItemType Directory -LiteralPath $parentDir -Force | Out-Null
    }
}

if ($PSCmdlet.ShouldProcess($Path, "Create File")) {
    $file = New-Item -LiteralPath $Path -ItemType File -Force
    Write-Host "File '$Path' was created."
    $file
}

