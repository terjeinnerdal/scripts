#!/usr/bin/env bash
#
# decrypt_file.sh - Decrypts a file using GnuPG (GPG).
#
# Supports decrypting both symmetric and asymmetric OpenPGP encrypted files.
#

set -euo pipefail

# --- Functions ---

# display_help prints CLI usage, options, and examples.
display_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <encrypted_file> [output_file]

Decrypts a GPG-encrypted file. Handles both symmetric (passphrase) and asymmetric (key pair) files.

Arguments:
  <encrypted_file>              Path to the encrypted file to decrypt (required).
  [output_file]                 Path for the decrypted file (optional).
                                Defaults to '<encrypted_file>' with '.gpg' or '.asc' stripped,
                                or '<encrypted_file>.decrypted' if no recognized extension exists.

Options:
  -o, --output <file>           Specify output file path (alternative to positional argument).
  -c, --stdout                  Write decrypted content directly to standard output.
  -f, --force                   Overwrite destination file without prompting if it already exists.
  -d, --delete                  Delete the encrypted source file upon successful decryption.
  -p, --passphrase <string>     Passphrase for decryption (note: visible in process list).
      --passphrase-file <file>  Read passphrase from specified file.
  -h, --help                    Display this help message and exit.

Environment Variables:
  GPG_PASSPHRASE                Passphrase for decryption (used if -p is omitted).
  GPG_PASSPHRASE_FILE           Path to file containing passphrase (used if --passphrase-file is omitted).

Examples:
  # Decrypt file to original filename (stripping .gpg or .asc extension):
  $(basename "$0") secret.txt.gpg

  # Decrypt to a specific destination file:
  $(basename "$0") secret.txt.gpg restored.txt

  # Decrypt and output directly to stdout:
  $(basename "$0") -c secret.txt.gpg

  # Decrypt non-interactively using an environment variable:
  GPG_PASSPHRASE="mypass" $(basename "$0") secret.txt.gpg
EOF
}

# Ensure gpg is installed
if ! command -v gpg >/dev/null 2>&1; then
    echo "Error: 'gpg' is required but not installed or not in PATH." >&2
    exit 1
fi

# --- Parameter Defaults ---
OUTPUT_FILE=""
TO_STDOUT=false
FORCE=false
DELETE_SOURCE=false
PASSPHRASE=""
PASSPHRASE_FILE=""
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
        -c|--stdout)
            TO_STDOUT=true
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
    echo "Error: No encrypted input file specified." >&2
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
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file '$INPUT_FILE' not found or is not a regular file." >&2
    exit 1
fi

# --- Determine Output Destination ---
if [[ "$TO_STDOUT" == false ]]; then
    if [[ -z "$OUTPUT_FILE" ]]; then
        if [[ "$INPUT_FILE" =~ \.gpg$ ]]; then
            OUTPUT_FILE="${INPUT_FILE%.gpg}"
        elif [[ "$INPUT_FILE" =~ \.asc$ ]]; then
            OUTPUT_FILE="${INPUT_FILE%.asc}"
        else
            OUTPUT_FILE="${INPUT_FILE}.decrypted"
        fi

        # If base name stripped results in empty or same as input file
        if [[ -z "$OUTPUT_FILE" || "$OUTPUT_FILE" == "$INPUT_FILE" ]]; then
            OUTPUT_FILE="${INPUT_FILE}.decrypted"
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
fi

# --- Build GPG Command ---
gpg_cmd=(gpg --quiet --no-greeting)

if [[ "$FORCE" == true || ( -n "$OUTPUT_FILE" && -e "$OUTPUT_FILE" ) ]]; then
    gpg_cmd+=(--yes)
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

gpg_cmd+=(--decrypt)

if [[ "$TO_STDOUT" == true ]]; then
    "${gpg_cmd[@]}" "$INPUT_FILE"
else
    gpg_cmd+=(-o "$OUTPUT_FILE" "$INPUT_FILE")
    echo "Decrypting '$INPUT_FILE' -> '$OUTPUT_FILE'..." >&2
    "${gpg_cmd[@]}"
    echo "Decryption completed successfully." >&2
fi

# --- Clean Up Source File If Requested ---
if [[ "$DELETE_SOURCE" == true ]]; then
    echo "Removing encrypted source file '$INPUT_FILE'..." >&2
    rm -f "$INPUT_FILE"
fi
