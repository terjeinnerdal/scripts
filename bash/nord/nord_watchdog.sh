#!/usr/bin/env bash
#
# nord_watchdog.sh - Monitors NordVPN daemon health, Meshnet state,
# peer routing permissions, and kernel IP forwarding for an exit node.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PEERS_FILE="$SCRIPT_DIR/peers.json"

# Load allowed routing peers from peers.json if available; fallback to default list
if command -v jq >/dev/null 2>&1 && [[ -f "$PEERS_FILE" ]] && jq -e '.allowed_for_routing' "$PEERS_FILE" >/dev/null 2>&1; then
    mapfile -t ROUTING_PEERS < <(jq -r '.allowed_for_routing[]' "$PEERS_FILE")
else
    ROUTING_PEERS=("mesh-tab8" "mesh-dell" "mesh-pixel" "sunndal")
fi

echo "Checking NordVPN status..."

# 1. Ensure the NordVPN daemon is running
if command -v systemctl >/dev/null 2>&1; then
    if ! systemctl is-active --quiet nordvpnd; then
        echo "NordVPN daemon is down. Restarting..."
        sudo systemctl start nordvpnd
        sleep 2
    fi
fi

# 2. Check if logged in (Exits if not)
if nordvpn account 2>&1 | grep -qi "not logged in"; then
    echo "Error: NordVPN is not logged in. Please login manually once." >&2
    exit 1
fi

# 3. Ensure Meshnet is ENABLED
if ! nordvpn settings | grep -q "Meshnet: enabled"; then
    echo "Enabling Meshnet..."
    nordvpn set meshnet on
fi

# 4. Ensure routing permissions are set for allowed peers
echo "Checking routing permissions..."
THIS_DEVICE=$(nordvpn meshnet peer list | grep -A 1 "This device:" | grep "Nickname:" | awk '{print $2}' || true)

for peer in "${ROUTING_PEERS[@]}"; do
    if [[ -n "$THIS_DEVICE" && "$peer" == "$THIS_DEVICE" ]]; then
        continue
    fi
    if ! nordvpn meshnet peer list | grep -A 10 "$peer" | grep -E -q "(Allow Routing:\s*enabled|Allowed to route traffic through you:\s*yes)"; then
        echo "Allowing peer '$peer' to route traffic through this device..."
        nordvpn meshnet peer routing allow "$peer"
    fi
done

# 5. Ensure IP Forwarding is active in the kernel
if [[ -f /proc/sys/net/ipv4/ip_forward ]]; then
    IF_FORWARD=$(cat /proc/sys/net/ipv4/ip_forward)
    if [[ "$IF_FORWARD" -eq 0 ]]; then
        echo "Enabling IP Forwarding..."
        sudo sysctl -w net.ipv4.ip_forward=1
    fi
fi

echo "NordVPN Exit Node is configured and ready."
