# DeleteEmptyFolders.ps1

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The root path to search for empty folders.")]
    [string]$Path
)

# Validate that the path exists and is a directory
if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "The path '$Path' does not exist or is not a folder."
    exit 1
}

Write-Verbose "Searching for empty folders under '$Path'..."

# Get all directories recursively, then filter for those that have no child items (files or folders).
# The results are sorted by the length of the FullName in descending order to ensure subdirectories are deleted before their parents.
Get-ChildItem -Path $Path -Recurse -Directory | Where-Object { -not $_.GetFileSystemInfos() } | Sort-Object { $_.FullName.Length } -Descending | Remove-Item -Force -Verbose

Write-Host "Finished deleting empty folders."