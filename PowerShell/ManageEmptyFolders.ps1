<#
.SYNOPSIS
  Finds and optionally deletes empty subdirectories within a specified path.

.DESCRIPTION
  This script acts as a CLI wrapper around the ManageEmptyFolders function.
  It recursively searches a given directory path for any subdirectories that are empty.
  By default, it lists the full paths of the empty folders found.
  When the -Delete switch is used, it will remove these empty folders, removing the deepest nested folders first.

.PARAMETER Path
  The root path to search for empty folders. This parameter is mandatory.

.PARAMETER Delete
  A switch parameter that, if present, causes the script to delete the empty folders it finds.

.EXAMPLE
  .\ManageEmptyFolders.ps1 -Path "C:\Users\Me\Documents"
  Description: Lists all empty folders found under C:\Users\Me\Documents.

.EXAMPLE
  .\ManageEmptyFolders.ps1 -Path "C:\Temp" -Delete
  Description: Deletes all empty folders found under C:\Temp after prompting for confirmation.

.EXAMPLE
  .\ManageEmptyFolders.ps1 -Path "C:\Temp" -Delete -WhatIf
  Description: Shows which empty folders would be deleted under C:\Temp without actually deleting them.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The root path to search for empty folders.")]
    [string]$Path,

    [Parameter(Mandatory = $false, HelpMessage = "If specified, the script will delete the empty folders found.")]
    [switch]$Delete
)

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

# Execute the core function passing through bound parameters
$results = ManageEmptyFolders @PSBoundParameters

if ($Delete.IsPresent) {
    $count = ($results | Measure-Object).Count
    Write-Host "Processed deletion of $count empty folder(s)." -ForegroundColor Yellow
}
else {
    $count = ($results | Measure-Object).Count
    Write-Host "Found $count empty folder(s):"
    $results | Select-Object -ExpandProperty FullName
}