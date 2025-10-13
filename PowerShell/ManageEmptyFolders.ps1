<#
.SYNOPSIS
  Finds and optionally deletes empty subdirectories within a specified path.

.DESCRIPTION
  This script recursively searches a given directory path for any subdirectories that are empty (contain no files or other subdirectories).
  By default, it lists the full paths of the empty folders found.
  When the -Delete switch is used, it will remove these empty folders. The deletion process is done safely by removing the deepest nested folders first.

.PARAMETER Path
  The root path to search for empty folders. This parameter is mandatory.

.PARAMETER Delete
  A switch parameter that, if present, causes the script to delete the empty folders it finds.

.EXAMPLE
  .\Manage-EmptyFolders.ps1 -Path "C:\Users\Me\Documents"
  Description: Lists all empty folders found under C:\Users\Me\Documents.

.EXAMPLE
  .\Manage-EmptyFolders.ps1 -Path "C:\Temp" -Delete
  Description: Deletes all empty folders found under C:\Temp after prompting for confirmation.

.EXAMPLE
  .\Manage-EmptyFolders.ps1 -Path "C:\Temp" -Delete -WhatIf
  Description: Shows which empty folders would be deleted under C:\Temp without actually deleting them.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The root path to search for empty folders.")]
    [string]$Path,

    [Parameter(Mandatory = $false, HelpMessage = "If specified, the script will delete the empty folders found.")]
    [switch]$Delete
)

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "The path '$Path' does not exist or is not a folder."
    exit 1
}

Write-Verbose "Searching for empty folders under '$Path'..."
$emptyFolders = Get-ChildItem -Path $Path -Recurse -Directory | Where-Object { -not $_.GetFileSystemInfos() }

if ($Delete) {
    Write-Host "Found $($emptyFolders.Count) empty folders to delete." -ForegroundColor Yellow
    # Sort by path length descending to delete deepest folders first
    $emptyFolders | Sort-Object { $_.FullName.Length } -Descending | ForEach-Object {
        if ($PSCmdlet.ShouldProcess($_.FullName, "Delete Empty Folder")) {
            Remove-Item -LiteralPath $_.FullName -Force -Verbose
        }
    }
    Write-Host "Finished deleting empty folders."
}
else {
    Write-Host "Found $($emptyFolders.Count) empty folders."
    # Default action: List the folders
    $emptyFolders | Select-Object -ExpandProperty FullName
}