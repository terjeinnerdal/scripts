#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <input_file> [output_file]"
    echo "Encrypts a file using AES-256-CBC with PBKDF2 key derivation."
    exit 1
}

if [[ $# -lt 1 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    usage
fi

INPUT_FILE="$1"
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file '$INPUT_FILE' does not exist." >&2
    exit 1
fi

OUTPUT_FILE="${2:-${INPUT_FILE}.enc}"

read -rsp "Enter encryption passphrase: " PASS1
echo
read -rsp "Confirm encryption passphrase: " PASS2
echo

if [[ "$PASS1" != "$PASS2" ]]; then
    echo "Error: Passphrases do not match." >&2
    exit 1
fi

if [[ -z "$PASS1" ]]; then
    echo "Error: Passphrase cannot be empty." >&2
    exit 1
fi

openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -in "$INPUT_FILE" -out "$OUTPUT_FILE" -pass pass:"$PASS1"

echo "File successfully encrypted to '$OUTPUT_FILE'."
