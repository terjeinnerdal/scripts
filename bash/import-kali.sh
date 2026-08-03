#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="/var/lib/libvirt/images"

# 1. Ensure a file argument was passed
if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/kali-linux-*-qemu-amd64.7z"
    exit 1
fi

ARCHIVE_PATH="$1"

if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "Error: File '$ARCHIVE_PATH' not found."
    exit 1
fi

# 2. Check for 7z extraction tool
if ! command -v 7z &> /dev/null; then
    echo "7z is not installed. Installing p7zip-full..."
    sudo apt update && sudo apt install -y p7zip-full
fi

# 3. Create a temporary working directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "--> Extracting archive to temporary directory..."
7z x "$ARCHIVE_PATH" -o"$TEMP_DIR" > /dev/null

# 4. Locate extracted .qcow2 file
QCOW2_FILE=$(find "$TEMP_DIR" -maxdepth 2 -type f -name "*.qcow2" | head -n 1)

if [ -z "$QCOW2_FILE" ]; then
    echo "Error: No .qcow2 file found inside the archive."
    exit 1
fi

FILE_NAME=$(basename "$QCOW2_FILE")
DEST_PATH="$DEST_DIR/$FILE_NAME"

echo "--> Moving disk image to $DEST_DIR..."
sudo mv "$QCOW2_FILE" "$DEST_PATH"

echo "--> Setting ownership and permissions..."
# libvirt requires read/write permissions for root:libvirt-qemu
sudo chown root:libvirt-qemu "$DEST_PATH"
sudo chmod 660 "$DEST_PATH"

echo "--> Done!"
echo "Image imported to: $DEST_PATH"
