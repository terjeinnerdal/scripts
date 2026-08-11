<#
.SYNOPSIS
    Deletes files based on path, filter, and age with safety dry-run support (-WhatIf).

.DESCRIPTION
    Safely removes files matching specified patterns and optionally older than a given number of days.
    Supports -WhatIf and -Confirm standard PowerShell switches.

.EXAMPLE
    .\DeleteFiles.ps1 -Path "C:\Logs" -Filter "*.log" -DaysOld 30 -Recurse -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Path = ".",

    [Parameter(Mandatory = $false)]
    [string]$Filter = "*",

    [Parameter(Mandatory = $false)]
    [int]$DaysOld = 0,

    [Parameter(Mandatory = $false)]
    [switch]$Recurse
)

if (-not (Test-Path -Path $Path)) {
    Write-Error "Target path '$Path' does not exist."
    exit 1
}

$cutoffDate = (Get-Date).AddDays(-$DaysOld)

$getParams = @{
    Path    = $Path
    Filter  = $Filter
    File    = $true
    Recurse = $Recurse
}

$filesToDelete = Get-ChildItem @getParams | Where-Object { $_.LastWriteTime -lt $cutoffDate }

if ($filesToDelete.Count -eq 0) {
    Write-Host "No files found matching criteria in '$Path'." -ForegroundColor Yellow
    return
}

Write-Host "Found $($filesToDelete.Count) file(s) to process." -ForegroundColor Cyan

foreach ($file in $filesToDelete) {
    if ($PSCmdlet.ShouldProcess($file.FullName, "Delete file")) {
        Remove-Item -Path $file.FullName -Force
        Write-Host "Deleted: $($file.FullName)" -ForegroundColor Green
    }
}
