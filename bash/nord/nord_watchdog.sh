#!/usr/bin/env bash

# Configuration - Add peer nicknames that should be allowed to route through this exit node.
# You can find peer nicknames with `nordvpn meshnet peer list`.
ROUTING_PEERS=("mesh-tab8" "mesh-dell" "mesh-hp" "mesh-pixel" "mesh-sunndal")

echo "Checking NordVPN status..."

# 1. Ensure the NordVPN daemon is running
if ! systemctl is-active --quiet nordvpnd; then
    echo "NordVPN daemon is down. Restarting..."
    sudo systemctl start nordvpnd
    sleep 2
fi

# 2. Check if logged in (Exits if not)
if ! nordvpn status | grep -q "Status:"; then
    echo "Error: NordVPN is not logged in. Please login manually once."
    exit 1
fi

# 3. Ensure Meshnet is ENABLED
if ! nordvpn settings | grep -q "Meshnet: enabled"; then
    echo "Enabling Meshnet..."
    nordvpn set meshnet on
fi

# 4. Ensure routing permissions are set for allowed peers
echo "Checking routing permissions..."
for peer in "${ROUTING_PEERS[@]}"; do
    if ! nordvpn meshnet peer list | grep -A 5 "$peer" | grep -q "Allowed to route traffic through you: yes"; then
        echo "Allowing peer '$peer' to route traffic through this device..."
        nordvpn meshnet peer routing allow "$peer"
    fi
done

# 5. Ensure IP Forwarding is active in the kernel
IF_FORWARD=$(cat /proc/sys/net/ipv4/ip_forward)
if [[ "$IF_FORWARD" -eq 0 ]]; then
    echo "Enabling IP Forwarding..."# 4. Ensure Exit Node permission is ACTIVE
# We check if the email is in the allowed list
if ! nordvpn meshnet peer list | grep -A 5 "This device" | grep -q "Allowing to use as exit node: yes"; then
    echo "Setting Exit Node permissions for $USER_EMAIL..."
    nordvpn meshnet peer allow-exit-node set "$USER_EMAIL"
fi

    sudo sysctl -w net.ipv4.ip_forward=1
fi

echo "NordVPN Exit Node is configured and ready."
