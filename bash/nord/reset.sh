#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0")"
    echo ""
    echo "Reconnects NordVPN by logging out, logging back in, and connecting to the default country/server."
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/logout.sh"
"$SCRIPT_DIR/login.sh"
"$SCRIPT_DIR/connect.sh"

