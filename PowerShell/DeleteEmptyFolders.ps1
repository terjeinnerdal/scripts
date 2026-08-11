<#
.SYNOPSIS
  Deletes empty subdirectories within a specified path (wrapper for ManageEmptyFolders.ps1).
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The root path to search for empty folders.")]
    [string]$Path
)

& "$PSScriptRoot/ManageEmptyFolders.ps1" -Path $Path -Delete