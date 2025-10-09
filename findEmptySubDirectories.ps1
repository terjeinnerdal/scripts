# findEmptySubDirectories.ps1

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The root path to search for empty directories.")]
    [string]$Path
)

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "The path '$Path' does not exist or is not a folder."
    exit 1
}

# Get all directories recursively, then filter for those that have no child items (files or folders).
Get-ChildItem -Path $Path -Recurse -Directory | Where-Object { -not $_.GetFileSystemInfos() } | Select-Object -ExpandProperty FullName