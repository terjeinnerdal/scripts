#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0")"
    echo ""
    echo "Logs out of NordVPN while persisting authentication token."
    exit 0
fi

nordvpn logout --persist-token true

