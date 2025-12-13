# This script starts the NextPVR container using Docker.
# NextPVR is a personal video recorder application.

docker run -d `
    --name nextpvr `
    --volume "/home/nextpvr/config:/config" `
    --volume "/media/terje/1TB/nextpvr/videos:/videos" `
    --volume "/media/terje/1TB/nextpvr/buffer:/buffer" `
    --restart unless-stopped `
    --publish 8866:8866 `
    --publish 16891:16891/udp `
    nextpvr/nextpvr_amd64:stable

Write-Host "NextPVR container is starting. Access it at http://localhost:8866"
