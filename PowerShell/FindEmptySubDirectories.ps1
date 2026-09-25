<#
.SYNOPSIS
  Recursively scans and outputs the full paths of all empty subdirectories under a given root path.

.DESCRIPTION
  This script searches the specified path for empty folders and outputs their full paths.

.PARAMETER Path
  The root path to search for empty directories. This parameter is mandatory.

.EXAMPLE
  .\FindEmptySubDirectories.ps1 -Path "C:\Users\Me\Documents"
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The root path to search for empty directories.")]
    [string]$Path
)

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    Write-Error "The path '$Path' does not exist or is not a folder."
    return
}

$functionFile = Join-Path -Path $PSScriptRoot -ChildPath "ManageEmptyFolders.Function.ps1"
if (-not (Test-Path -LiteralPath $functionFile)) {
    throw "Required function file '$functionFile' was not found."
}
. $functionFile

ManageEmptyFolders -Path $Path | Select-Object -ExpandProperty FullName