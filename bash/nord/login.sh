#!/usr/bin/env bash
set -euo pipefail

echo "$(dirname "$0")"
echo "$NORDVPN_TOKEN"

TOKEN_FILE="$(dirname "$0")/access_token.txt"
if [ -n "${NORDVPN_TOKEN:-}" ]; then
    TOKEN="$NORDVPN_TOKEN"
elif [ -f "$TOKEN_FILE" ]; then
    TOKEN=$(tr -d '\r\n' < "$TOKEN_FILE")
else
    echo "Error: Token not found in $TOKEN_FILE or \$NORDVPN_TOKEN environment variable." >&2
    exit 1
fi

nordvpn login --token "$TOKEN"
