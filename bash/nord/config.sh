#! /usr/bin/bash


# Check for jq
if ! command -v jq &> /dev/null
then
    echo "Error: 'jq' is not installed. Please install 'jq' to parse the peers JSON file." >&2
    echo "On Debian/Ubuntu: sudo apt-get install jq" >&2
    exit 1
fi

# Function to display usage information
display_help() {
    echo "Usage: $0 <nickname>"
    echo ""
    echo "Configures NordVPN Meshnet settings for a device."
    echo "  <nickname>  The desired nickname for this device in NordVPN Meshnet."
}

if [ "$1" == "--help" ]; then
    display_help
    exit 0
fi

if [ -z "$1" ]; then
    echo "Error: No nickname provided." >&2
    display_help
    exit 1
fi

echo "The nickname is: $1"

NICKNAME=$1

nordvpn set meshnet off
nordvpn set routing disable
nordvpn set meshnet on
nordvpn meshnet set nickname $NICKNAME

nordvpn set notify on

nordvpn set pq off
nordvpn set lan-discovery off
nordvpn set technology nordlynx

# Set auto-connect for this device
nordvpn set autoconnect on

PEERS_FILE="$(dirname "$0")/peers.json"

# Check if the peers file exists
if [ ! -f "$PEERS_FILE" ]; then
    echo "Error: Peers configuration file not found at '$PEERS_FILE'." >&2
    echo "Please create a JSON file at this location with an 'allowed_for_fileshare' key." >&2
    exit 1
fi

echo "Reading allowed peers for filesharing from '$PEERS_FILE'..."
if ! mapfile -t FILESHARE_PEERS < <(jq -r '.allowed_for_fileshare[]' "$PEERS_FILE"); then
    echo "Error: Failed to parse 'allowed_for_fileshare' from '$PEERS_FILE'." >&2
    echo "Please ensure it's a valid JSON file with an 'allowed_for_fileshare' key containing an array of strings." >&2
    exit 1
fi

echo "Reading all peers from '$PEERS_FILE'..."
if ! mapfile -t ALL_PEERS < <(jq -r '.all_peers[]' "$PEERS_FILE"); then
    echo "Error: Failed to parse 'all_peers' from '$PEERS_FILE'." >&2
    echo "Please ensure it's a valid JSON file with an 'all_peers' key containing an array of strings." >&2
    exit 1
fi

echo "Configuring fileshare and auto-accept for specific peers..."
for PEER in "${FILESHARE_PEERS[@]}"; do
    nordvpn meshnet peer fileshare allow "$PEER" && echo "  - Allowed fileshare for '$PEER'."
    nordvpn meshnet peer auto-accept enable "$PEER" && echo "  - Enabled auto-accept for '$PEER'."
done

# Function to disable fileshare for peers not in the allowlist.
disable_fileshare_for_unallowed_peers() {
    echo "Disabling fileshare for peers not on the allowlist..."
    for PEER in "${ALL_PEERS[@]}"; do
        # Don't try to change permissions for the device this script is running on.
        if [[ "$PEER" == "$NICKNAME" ]]; then
            continue
        fi

        # Check if the peer is in the FILESHARE_PEERS array.
        # The '!' negates the result, so this runs if the peer is NOT found.
        if ! printf '%s\n' "${FILESHARE_PEERS[@]}" | grep -q -x "$PEER"; then
            nordvpn meshnet peer fileshare deny "$PEER" && echo "  - Disabled fileshare for '$PEER'."
        fi
    done
}

# Ensure peers not explicitly allowed cannot fileshare.
disable_fileshare_for_unallowed_peers

echo "Configuration complete."
