#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0")"
    echo ""
    echo "Authenticates to NordVPN using \$NORDVPN_TOKEN or a local access_token.txt file."
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOKEN_FILE="$SCRIPT_DIR/access_token.txt"
ALT_TOKEN_FILE="$SCRIPT_DIR/nord_access_token.txt"

if [ -n "${NORDVPN_TOKEN:-}" ]; then
    TOKEN="$NORDVPN_TOKEN"
elif [ -f "$TOKEN_FILE" ]; then
    TOKEN=$(tr -d '\r\n' < "$TOKEN_FILE")
elif [ -f "$ALT_TOKEN_FILE" ]; then
    TOKEN=$(tr -d '\r\n' < "$ALT_TOKEN_FILE")
else
    echo "Error: Token not found in $TOKEN_FILE or \$NORDVPN_TOKEN environment variable." >&2
    exit 1
fi

nordvpn login --token "$TOKEN"

