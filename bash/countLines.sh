#!/usr/bin/env bash
set -euo pipefail

display_help() {
    echo "Usage: $(basename "$0") <file>"
    echo ""
    echo "Reads a file line by line, printing each line with its 1-based line number,"
    echo "and displays the total line count."
}

if [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    display_help
    exit 0
fi

FILENAME="$1"

if [[ ! -f "$FILENAME" ]]; then
    echo "Error: File '$FILENAME' not found or is not a regular file." >&2
    exit 1
fi

COUNTER=0
while IFS= read -r line || [[ -n "$line" ]]; do
    COUNTER=$((COUNTER + 1))
    echo "${COUNTER}: ${line}"
done < "$FILENAME"

echo "Total: ${COUNTER}"
