#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0") [country/server/peer]"
    echo ""
    echo "Connects to a VPN server or Meshnet peer. Defaults to 'NO'."
    exit 0
fi

country="${1:-NO}"

echo "Connecting to: $country"
nordvpn connect "$country"

