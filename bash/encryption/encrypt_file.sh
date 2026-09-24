#!/usr/bin/env bash
#
# encrypt_file.sh - Encrypts a file using GnuPG (GPG).
#
# Supports symmetric encryption (passphrase with AES256 by default)
# as well as asymmetric encryption using one or more public key recipients.
#

set -euo pipefail

# --- Functions ---

# display_help prints CLI usage, options, and examples.
display_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <input_file> [output_file]

Encrypts a file using GnuPG (GPG). By default, symmetric encryption (AES256) is used.

Arguments:
  <input_file>                  Path to the file to encrypt (required).
  [output_file]                 Path for the encrypted file (optional).
                                Defaults to '<input_file>.gpg' (or '<input_file>.asc' if --armor is used).

Options:
  -s, --symmetric               Encrypt symmetrically with a passphrase using AES256 (default).
  -r, --recipient <key_id>      Encrypt asymmetrically for the given recipient public key or email.
                                Can be specified multiple times for multiple recipients.
  -a, --armor                   Create ASCII-armored output (.asc extension by default).
  -o, --output <file>           Specify output file path (alternative to positional argument).
  -f, --force                   Overwrite destination file without prompting if it already exists.
  -d, --delete                  Securely shred/remove the original unencrypted file upon successful encryption.
  -p, --passphrase <string>     Passphrase for encryption (note: visible in process list).
      --passphrase-file <file>  Read passphrase from specified file.
  -h, --help                    Display this help message and exit.

Environment Variables:
  GPG_PASSPHRASE                Passphrase for symmetric encryption (used if -p is omitted).
  GPG_PASSPHRASE_FILE           Path to file containing passphrase (used if --passphrase-file is omitted).

Examples:
  # Encrypt symmetrically (prompts for passphrase):
  $(basename "$0") secret.txt

  # Encrypt to a specific output file:
  $(basename "$0") secret.txt encrypted_secret.gpg

  # Encrypt with ASCII armor:
  $(basename "$0") -a secret.txt

  # Encrypt for a recipient using their public key:
  $(basename "$0") -r user@example.com secret.txt

  # Encrypt and shred the original unencrypted file:
  $(basename "$0") -d secret.txt
EOF
}

# Ensure gpg is installed
if ! command -v gpg >/dev/null 2>&1; then
    echo "Error: 'gpg' is required but not installed or not in PATH." >&2
    exit 1
fi

# --- Parameter Defaults ---
OUTPUT_FILE=""
ARMOR=false
FORCE=false
DELETE_SOURCE=false
PASSPHRASE=""
PASSPHRASE_FILE=""
RECIPIENTS=()
POSITIONAL_ARGS=()

# --- Parse Arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            display_help
            exit 0
            ;;
        -o|--output)
            if [[ -z "${2:-}" ]]; then
                echo "Error: '$1' requires a file path argument." >&2
                exit 1
            fi
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -r|--recipient)
            if [[ -z "${2:-}" ]]; then
                echo "Error: '$1' requires a recipient key ID or email argument." >&2
                exit 1
            fi
            RECIPIENTS+=("$2")
            shift 2
            ;;
        -s|--symmetric)
            shift
            ;;
        -a|--armor)
            ARMOR=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -d|--delete)
            DELETE_SOURCE=true
            shift
            ;;
        -p|--passphrase)
            if [[ -z "${2:-}" ]]; then
                echo "Error: '$1' requires a passphrase argument." >&2
                exit 1
            fi
            PASSPHRASE="$2"
            shift 2
            ;;
        --passphrase-file)
            if [[ -z "${2:-}" ]]; then
                echo "Error: '$1' requires a file path argument." >&2
                exit 1
            fi
            PASSPHRASE_FILE="$2"
            shift 2
            ;;
        --)
            shift
            while [[ $# -gt 0 ]]; do
                POSITIONAL_ARGS+=("$1")
                shift
            done
            break
            ;;
        -*)
            echo "Error: Unknown option '$1'." >&2
            echo "Run '$(basename "$0") --help' for usage instructions." >&2
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# --- Validate Positional Arguments ---
if [[ ${#POSITIONAL_ARGS[@]} -eq 0 ]]; then
    echo "Error: No input file specified." >&2
    echo "Run '$(basename "$0") --help' for usage instructions." >&2
    exit 1
fi

INPUT_FILE="${POSITIONAL_ARGS[0]}"

if [[ -z "$OUTPUT_FILE" && ${#POSITIONAL_ARGS[@]} -ge 2 ]]; then
    OUTPUT_FILE="${POSITIONAL_ARGS[1]}"
fi

if [[ ${#POSITIONAL_ARGS[@]} -gt 2 ]]; then
    echo "Error: Unexpected additional arguments: ${POSITIONAL_ARGS[*]:2}" >&2
    exit 1
fi

# --- Validate Input File ---
if [[ -d "$INPUT_FILE" ]]; then
    echo "Error: '$INPUT_FILE' is a directory. Please compress it first (e.g. tar -czf archive.tar.gz ...) or provide a file." >&2
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file '$INPUT_FILE' not found or is not a regular file." >&2
    exit 1
fi

# --- Determine Output File ---
if [[ -z "$OUTPUT_FILE" ]]; then
    if [[ "$ARMOR" == true ]]; then
        OUTPUT_FILE="${INPUT_FILE}.asc"
    else
        OUTPUT_FILE="${INPUT_FILE}.gpg"
    fi
fi

# Check for identical source and destination
if [[ "$INPUT_FILE" -ef "$OUTPUT_FILE" ]] 2>/dev/null || [[ "$INPUT_FILE" == "$OUTPUT_FILE" ]]; then
    echo "Error: Output file cannot be the same as input file ('$INPUT_FILE')." >&2
    exit 1
fi

# Validate output directory
OUT_DIR="$(dirname "$OUTPUT_FILE")"
if [[ ! -d "$OUT_DIR" ]]; then
    echo "Error: Destination directory '$OUT_DIR' does not exist." >&2
    exit 1
fi

# Check if destination exists
if [[ -e "$OUTPUT_FILE" && "$FORCE" != true ]]; then
    if [[ -t 0 ]]; then
        read -r -p "Output file '$OUTPUT_FILE' already exists. Overwrite? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Operation aborted." >&2
            exit 1
        fi
    else
        echo "Error: Output file '$OUTPUT_FILE' already exists. Use -f or --force to overwrite." >&2
        exit 1
    fi
fi

# --- Build GPG Command ---
gpg_cmd=(gpg --quiet --no-greeting)

if [[ "$FORCE" == true || -e "$OUTPUT_FILE" ]]; then
    gpg_cmd+=(--yes)
fi

if [[ "$ARMOR" == true ]]; then
    gpg_cmd+=(--armor)
fi

# Check environment variables and local fallback for passphrase if not set via flags
PASSPHRASE="${PASSPHRASE:-${GPG_PASSPHRASE:-}}"
PASSPHRASE_FILE="${PASSPHRASE_FILE:-${GPG_PASSPHRASE_FILE:-}}"
LOCAL_PASSPHRASE_FILE="$(dirname "$0")/passphrase.txt"

if [[ -z "$PASSPHRASE" && -z "$PASSPHRASE_FILE" && -f "$LOCAL_PASSPHRASE_FILE" ]]; then
    PASSPHRASE_FILE="$LOCAL_PASSPHRASE_FILE"
fi

if [[ -n "$PASSPHRASE" ]]; then
    gpg_cmd+=(--batch --pinentry-mode loopback --passphrase "$PASSPHRASE")
elif [[ -n "$PASSPHRASE_FILE" ]]; then
    if [[ ! -f "$PASSPHRASE_FILE" ]]; then
        echo "Error: Passphrase file '$PASSPHRASE_FILE' not found." >&2
        exit 1
    fi
    gpg_cmd+=(--batch --pinentry-mode loopback --passphrase-file "$PASSPHRASE_FILE")
fi

if [[ ${#RECIPIENTS[@]} -gt 0 ]]; then
    gpg_cmd+=(--encrypt)
    for recipient in "${RECIPIENTS[@]}"; do
        gpg_cmd+=(-r "$recipient")
    done
else
    # Default to symmetric encryption using AES256
    gpg_cmd+=(--symmetric --cipher-algo AES256)
fi

gpg_cmd+=(-o "$OUTPUT_FILE" "$INPUT_FILE")

# --- Execute Encryption ---
echo "Encrypting '$INPUT_FILE' -> '$OUTPUT_FILE'..." >&2
"${gpg_cmd[@]}"
echo "Encryption completed successfully." >&2

# --- Clean Up Source File If Requested ---
if [[ "$DELETE_SOURCE" == true ]]; then
    if command -v shred >/dev/null 2>&1; then
        echo "Securely shredding unencrypted file '$INPUT_FILE'..." >&2
        shred -u "$INPUT_FILE"
    else
        echo "Removing unencrypted file '$INPUT_FILE'..." >&2
        rm -f "$INPUT_FILE"
    fi
fi
