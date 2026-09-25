#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0")"
    echo ""
    echo "Removes snapd and any leftover orphaned packages via apt autoremove."
    exit 0
fi

sudo apt autoremove -y snapd


