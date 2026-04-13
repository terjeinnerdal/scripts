#! /usr/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install 'jq' to parse the peers JSON file." >&2
    echo "On Debian/Ubuntu: sudo apt-get install jq" >&2
    exit 1
fi

# Function to display usage information
display_help() {
    echo "Usage: $0 <nickname_for_this_device>"
    echo ""
    echo "Configures the current device (e.g., Raspberry Pi) to act as an exit node for specific Meshnet peers."
    echo "This script enables Meshnet, sets a nickname for the device, and allows specified peers to route through it."
    echo ""
    echo "Arguments:"
    echo "  <nickname_for_this_device>  The desired nickname for this device in NordVPN Meshnet (e.g., 'mesh-raspberry')."
    echo ""
    echo "Example:"
    echo "  $0 mesh-raspberry"
}

if [ "$1" == "--help" ]; then
    display_help
    exit 0
fi

if [ -z "$1" ]; then
    echo "Error: No nickname provided for this device." >&2
    display_help
    exit 1
fi

NICKNAME="$1"
echo "Configuring '$NICKNAME' to be a NordVPN Meshnet exit node..."

# Enable Meshnet and set the device's nickname
nordvpn set meshnet on && echo "Meshnet enabled."
nordvpn meshnet set nickname "$NICKNAME" && echo "Nickname set to '$NICKNAME'."

# Define the path to the JSON file containing allowed peers
PEERS_FILE="$(dirname "$0")/peers.json"

# Check if the peers file exists
if [ ! -f "$PEERS_FILE" ]; then
    echo "Error: Peers configuration file not found at '$PEERS_FILE'." >&2
    echo "Please create a JSON file at this location with 'allowed_for_routing' and 'allowed_for_local' keys." >&2
    echo "Example: { \"allowed_for_routing\": [\"mesh-tab8\"], \"allowed_for_local\": [\"mesh-dell\"] }" >&2
    exit 1
fi

echo "Reading all peers from '$PEERS_FILE'..."
if ! mapfile -t ALL_PEERS < <(jq -r '.all_peers[]' "$PEERS_FILE"); then
    echo "Error: Failed to parse 'all_peers' from '$PEERS_FILE'." >&2
    echo "Please ensure it's a valid JSON file with an 'all_peers' key containing an array of strings." >&2
    exit 1
fi

echo "Reading allowed peers for routing from '$PEERS_FILE'..."
if ! mapfile -t ROUTING_PEERS < <(jq -r '.allowed_for_routing[]' "$PEERS_FILE"); then
    echo "Error: Failed to parse 'allowed_for_routing' from '$PEERS_FILE'." >&2
    echo "Please ensure it's a valid JSON file with an 'allowed_for_routing' key containing an array of strings." >&2
    exit 1
fi

echo "Reading allowed peers for local network access from '$PEERS_FILE'..."
if ! mapfile -t LOCAL_PEERS < <(jq -r '.allowed_for_local[]' "$PEERS_FILE"); then
    echo "Error: Failed to parse 'allowed_for_local' from '$PEERS_FILE'." >&2
    echo "Please ensure it's a valid JSON file with an 'allowed_for_local' key containing an array of strings." >&2
    exit 1
fi

echo "Allowing specific peers to route through '$NICKNAME':"
for PEER in "${ROUTING_PEERS[@]}"; do
    nordvpn meshnet peer routing allow "$PEER" && echo "  - Allowed '$PEER' to route through this device."
done

echo "Allowing specific peers to access this device's local network:"
for PEER in "${LOCAL_PEERS[@]}"; do
    nordvpn meshnet peer local allow "$PEER" && echo "  - Allowed '$PEER' to access this device's local network."
done

# Function to disable routing for peers not in the allowlist.
disable_routing_for_unallowed_peers() {
    echo "Disabling routing for peers not on the allowlist..."
    for PEER in "${ALL_PEERS[@]}"; do
        # Don't try to change permissions for the device this script is running on.
        if [[ "$PEER" == "$NICKNAME" ]]; then
            continue
        fi

        # Check if the peer is in the ROUTING_PEERS array.
        # The '!' negates the result, so this runs if the peer is NOT found.
        if ! printf '%s\n' "${ROUTING_PEERS[@]}" | grep -q -x "$PEER"; then
            nordvpn meshnet peer routing deny "$PEER" && echo "  - Disabled routing for '$PEER'."
        fi
    done
}

# Ensure peers not explicitly allowed cannot route through this device.
disable_routing_for_unallowed_peers

echo "Configuration complete. Check status with 'nordvpn meshnet peer list'."
