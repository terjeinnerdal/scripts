#!/usr/bin/env bash
set -euo pipefail

# --- Dependency Checks ---
command -v nordvpn >/dev/null 2>&1 || {
  echo "nordvpn CLI not found in PATH" >&2
  exit 1
}

if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install 'jq' to parse the peers JSON file." >&2
    echo "On Debian/Ubuntu: sudo apt-get install jq" >&2
    exit 1
fi

# --- Configuration ---
PEERS_FILE="$(dirname "$0")/peers.json"

# --- Functions ---

# display_help prints usage and describes supported modes and the optional nickname for configuring NordVPN Meshnet.
display_help() {
    echo "Usage: $0 <mode> [nickname]"
    echo ""
    echo "Configures NordVPN Meshnet for this device."
    echo ""
    echo "Modes:"
    echo "  --peer         Configure as a standard peer with filesharing and auto-connect."
    echo "  --exit-node    Configure as an exit node for routing traffic for other peers."
    echo "  --help         Display this help message."
    echo ""
    echo "Arguments:"
    echo "  [nickname]     Optional. The desired nickname for this device. If not provided, an existing nickname will be used."
}

# get_nickname selects and echoes the Meshnet device nickname.
# If a positional argument is provided, that value is echoed.
# Otherwise it queries `nordvpn` for this device's existing nickname and echoes it.
# If no nickname can be determined, it prints help and exits with status 1.
get_nickname() {
    # Use provided nickname if available
    if [ -n "${1:-}" ]; then
        echo "${1}"
        return
    fi

    # Otherwise, try to find an existing nickname for the device.
    local existing_nickname
    existing_nickname=$(nordvpn meshnet peer list | grep -A 1 "This device:" | grep "Nickname:" | awk '{print $2}' || true)

    if [ -n "$existing_nickname" ]; then
        echo "No nickname provided. Using existing nickname: $existing_nickname" >&2
        echo "$existing_nickname"
        return
    fi

    # If no nickname is provided and none exists, it's an error.
    echo "Error: No nickname provided and no existing nickname found." >&2
    display_help
    exit 1
}

# configure_as_peer configures the device as a standard Meshnet peer: applies general NordVPN settings and sets fileshare permissions based on `allowed_for_fileshare` and `all_peers` in the peers.json file, taking the device nickname as its first argument.
configure_as_peer() {
    local nickname=$1
    echo "Configuring device as a standard peer..."

    # Set general NordVPN settings
    nordvpn set notify on
    nordvpn set pq off
    nordvpn set lan-discovery off
    nordvpn set technology nordlynx
    nordvpn set autoconnect on NO
    echo "Applied general VPN settings (NordLynx, autoconnect, etc.)."

    # Configure fileshare permissions
    if ! jq -e '.allowed_for_fileshare' "$PEERS_FILE" > /dev/null; then
        echo "Warning: 'allowed_for_fileshare' key not found in '$PEERS_FILE'. Skipping fileshare configuration." >&2
        return
    fi

    local -a fileshare_peers
    if ! mapfile -t fileshare_peers < <(jq -r '.allowed_for_fileshare[]' "$PEERS_FILE"); then
        echo "Error: Failed to parse 'allowed_for_fileshare' from '$PEERS_FILE'." >&2
        return
    fi

    echo "Configuring fileshare permissions..."
    for peer in "${fileshare_peers[@]}"; do
        nordvpn meshnet peer fileshare allow "$peer" && echo "  - Allowed fileshare for '$peer'."
        nordvpn meshnet peer auto-accept enable "$peer" && echo "  - Enabled auto-accept for '$peer'."
    done

    # Deny fileshare for all other peers
    if jq -e '.all_peers' "$PEERS_FILE" > /dev/null; then
        local -a all_peers
        mapfile -t all_peers < <(jq -r '.all_peers[]' "$PEERS_FILE")
        echo "Disabling fileshare for peers not on the allowlist..."
        for peer in "${all_peers[@]}"; do
            if [[ "$peer" == "$nickname" ]]; then continue; fi
            if ! printf '%s\n' "${fileshare_peers[@]}" | grep -q -x "$peer"; then
                nordvpn meshnet peer fileshare deny "$peer" && echo "  - Disabled fileshare for '$peer'."
            fi
        done
    fi
}

# configure_as_exit_node configures the device as a NordVPN Meshnet exit node by allowing routing and local-network access for peers listed in peers.json and denying routing for peers not on the routing allowlist when applicable.
# nickname: device nickname used to exclude the local device from deny rules and to label status messages.
configure_as_exit_node() {
    local nickname=$1
    echo "Configuring device as an exit node..."

    # Configure routing permissions
    if jq -e '.allowed_for_routing' "$PEERS_FILE" > /dev/null; then
        local -a routing_peers
        if ! mapfile -t routing_peers < <(jq -r '.allowed_for_routing[]' "$PEERS_FILE"); then
            echo "Error: Failed to parse 'allowed_for_routing' from '$PEERS_FILE'." >&2
        else
            echo "Allowing specific peers to route through '$nickname':"
            for peer in "${routing_peers[@]}"; do
                nordvpn meshnet peer routing allow "$peer" && echo "  - Allowed '$peer' to route through this device."
            done
        fi
    else
        echo "Warning: 'allowed_for_routing' key not found in '$PEERS_FILE'. Skipping routing configuration." >&2
    fi

    # Configure local network access permissions
    if jq -e '.allowed_for_local' "$PEERS_FILE" > /dev/null; then
        local -a local_peers
        if ! mapfile -t local_peers < <(jq -r '.allowed_for_local[]' "$PEERS_FILE"); then
            echo "Error: Failed to parse 'allowed_for_local' from '$PEERS_FILE'." >&2
        else
            echo "Allowing specific peers to access this device's local network:"
            for peer in "${local_peers[@]}"; do
                nordvpn meshnet peer local allow "$peer" && echo "  - Allowed '$peer' to access this device's local network."
            done
        fi
    else
        echo "Warning: 'allowed_for_local' key not found in '$PEERS_FILE'. Skipping local network access configuration." >&2
    fi

    # Deny routing for all other peers
    if jq -e '.all_peers' "$PEERS_FILE" > /dev/null && jq -e '.allowed_for_routing' "$PEERS_FILE" > /dev/null; then
        local -a all_peers
        mapfile -t all_peers < <(jq -r '.all_peers[]' "$PEERS_FILE")
        local -a routing_peers
        mapfile -t routing_peers < <(jq -r '.allowed_for_routing[]' "$PEERS_FILE")

        echo "Disabling routing for peers not on the allowlist..."
        for peer in "${all_peers[@]}"; do
            if [[ "$peer" == "$nickname" ]]; then continue; fi
            if ! printf '%s\n' "${routing_peers[@]}" | grep -q -x "$peer"; then
                nordvpn meshnet peer routing deny "$peer" && echo "  - Disabled routing for '$peer'."
            fi
        done
    fi
}


# --- Main Script ---

# Check for a mode argument
if [ -z "${1:-}" ] || [[ "$1" != --* ]]; then
    echo "Error: No mode specified or invalid argument." >&2
    display_help
    exit 1
fi

MODE="$1"
NICKNAME_ARG="${2:-}"

# Handle help flag
if [ "$MODE" == "--help" ]; then
    display_help
    exit 0
fi

# Check if the peers file exists
if [ ! -f "$PEERS_FILE" ]; then
    echo "Error: Peers configuration file not found at '$PEERS_FILE'." >&2
    echo "Please create a JSON file at this location with the necessary peer lists." >&2
    exit 1
fi

# Get the nickname for the device
NICKNAME=$(get_nickname "$NICKNAME_ARG")
echo "Using nickname: $NICKNAME"

# Common setup for all modes
echo "Performing common setup..."
nordvpn set meshnet on && echo "Meshnet enabled."
nordvpn meshnet set nickname "$NICKNAME" && echo "Nickname set to '$NICKNAME'."

# Execute mode-specific configuration
case "$MODE" in
    --peer)
        configure_as_peer "$NICKNAME"
        ;;
    --exit-node)
        configure_as_exit_node "$NICKNAME"
        ;;
    *)
        echo "Error: Invalid mode '$MODE'." >&2
        display_help
        exit 1
        ;;
esac

echo "Configuration complete."
