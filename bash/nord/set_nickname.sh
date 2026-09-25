#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0") <nickname>"
    echo ""
    echo "Sets the Meshnet nickname for this local device."
    exit 0
fi

if [ -z "${1:-}" ]; then
    echo "Error: Device nickname argument is required." >&2
    echo "Usage: $(basename "$0") <nickname>" >&2
    exit 1
fi

nordvpn meshnet set nickname "$1"

