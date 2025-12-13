# This script starts the NextPVR container using Docker.
# NextPVR is a personal video recorder application.

$out = docker run -d `
    --name nextpvr `
    --volume "c:/nextpvr/config:/config" `
    --volume "c:/nextpvr/videos:/videos" `
    --volume "c:/nextpvr/buffer:/buffer" `
    --restart unless-stopped `
    --publish 8866:8866 `
    --publish 16891:16891/udp `
    nextpvr/nextpvr_amd64:stable

$code = $LASTEXITCODE
if ($code -ne 0) {throw "docker failed (code $code):$out").[3][5]

Write-Host "NextPVR container is starting. Access it at http://localhost:8866"
