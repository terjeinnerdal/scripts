#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <encrypted_file> [output_file]"
    echo "Decrypts a file encrypted with encrypt_file.sh."
    exit 1
}

if [[ $# -lt 1 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    usage
fi

INPUT_FILE="$1"
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Encrypted file '$INPUT_FILE' does not exist." >&2
    exit 1
fi

if [[ $# -ge 2 ]]; then
    OUTPUT_FILE="$2"
elif [[ "$INPUT_FILE" == *.enc ]]; then
    OUTPUT_FILE="${INPUT_FILE%.enc}"
else
    OUTPUT_FILE="${INPUT_FILE}.dec"
fi

read -rsp "Enter decryption passphrase: " PASS
echo

if [[ -z "$PASS" ]]; then
    echo "Error: Passphrase cannot be empty." >&2
    exit 1
fi

if openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in "$INPUT_FILE" -out "$OUTPUT_FILE" -pass pass:"$PASS"; then
    echo "File successfully decrypted to '$OUTPUT_FILE'."
else
    echo "Error: Decryption failed. Incorrect passphrase or corrupted file." >&2
    rm -f "$OUTPUT_FILE"
    exit 1
fi
