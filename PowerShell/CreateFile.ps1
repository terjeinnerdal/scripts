# CreateFile.ps1
Param (
  [Parameter(Mandatory = $true)]
  [string]$Path
)

if (Test-Path -Path $Path) {
  Write-Warning "File '$Path' already exists."
}
else {
  New-Item -Path $Path -ItemType File | Out-Null # Creates a new file at $Path.
  Write-Host "File '$Path' was created."
}
