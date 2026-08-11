<#
.SYNOPSIS
  Finds empty subdirectories within a specified path (wrapper for ManageEmptyFolders.ps1).
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The root path to search for empty directories.")]
    [string]$Path
)

& "$PSScriptRoot/ManageEmptyFolders.ps1" -Path $Path