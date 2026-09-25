<#
.SYNOPSIS
  Recursively searches and deletes empty folders under a specified path.

.DESCRIPTION
  This script safely deletes empty folders under the specified path, removing deepest nested folders first.
  Supports -WhatIf, -Confirm, and -Verbose.

.PARAMETER Path
  The root path to search for empty folders. This parameter is mandatory.

.EXAMPLE
  .\DeleteEmptyFolders.ps1 -Path "C:\Temp" -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The root path to search for empty folders.")]
    [string]$Path
)

# Validate that the path exists and is a directory
if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    Write-Error "The path '$Path' does not exist or is not a folder."
    return
}

# Dot-source the reusable function
$functionFile = Join-Path -Path $PSScriptRoot -ChildPath "ManageEmptyFolders.Function.ps1"
if (-not (Test-Path -LiteralPath $functionFile)) {
    throw "Required function file '$functionFile' was not found."
}
. $functionFile

# Delegate deletion to ManageEmptyFolders with -Delete
$params = @{}
foreach ($key in $PSBoundParameters.Keys) {
    $params[$key] = $PSBoundParameters[$key]
}
$params['Delete'] = $true

$deleted = ManageEmptyFolders @params
$count = ($deleted | Measure-Object).Count
Write-Host "Finished deleting $count empty folder(s)."