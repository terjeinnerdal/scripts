#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0")"
    echo ""
    echo "Disconnects from the active NordVPN server or peer."
    exit 0
fi

nordvpn disconnect