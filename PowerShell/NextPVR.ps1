<#
.SYNOPSIS
  Starts the NextPVR Docker container.

.DESCRIPTION
  Runs the NextPVR personal video recorder container with customizable volume paths
  and network port bindings. Honors -WhatIf and -Confirm.

.PARAMETER BasePath
  The host directory path for NextPVR config, videos, and buffer folders. Defaults to 'c:/nextpvr'.

.PARAMETER ContainerName
  The name for the Docker container. Defaults to 'nextpvr'.

.EXAMPLE
  .\NextPVR.ps1 -BasePath "c:/nextpvr"

.EXAMPLE
  .\NextPVR.ps1 -BasePath "/var/lib/nextpvr" -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param (
    [Parameter(Mandatory = $false)]
    [string]$BasePath = "c:/nextpvr",

    [Parameter(Mandatory = $false)]
    [string]$ContainerName = "nextpvr"
)

# Check if container is already running or exists
$existingStatus = docker ps -a --filter "name=^/${ContainerName}$" --format "{{.Status}}" 2>$null
if ($existingStatus) {
    if ($existingStatus -like "Up*") {
        Write-Host "Container '$ContainerName' is already running." -ForegroundColor Green
        return
    }
    else {
        Write-Warning "Container '$ContainerName' exists but is stopped. Starting existing container..."
        if ($PSCmdlet.ShouldProcess($ContainerName, "Start Docker Container")) {
            docker start $ContainerName | Out-Null
        }
        return
    }
}

if ($PSCmdlet.ShouldProcess($ContainerName, "Run Docker Container")) {
    docker run -d `
        --name $ContainerName `
        --volume "${BasePath}/config:/config" `
        --volume "${BasePath}/videos:/videos" `
        --volume "${BasePath}/buffer:/buffer" `
        --restart unless-stopped `
        --publish 8866:8866 `
        --publish 16891:16891/udp `
        nextpvr/nextpvr_amd64:stable | Out-Null

    Write-Host "NextPVR container is starting. Access it at http://localhost:8866"
}

