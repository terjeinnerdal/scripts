#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0") [filter]"
    echo ""
    echo "Lists available Meshnet peers. Filter defaults to 'online'."
    exit 0
fi

filter="${1:-online}"
echo "Filter: $filter"

nordvpn meshnet peer list --filter="$filter"

