#! /usr/bin/bash
set -euo pipefail

command -v nordvpn >/dev/null 2>&1 || {
  echo "nordvpn CLI not found in PATH" >&2
  exit 1
}

# Enable meshnet
nordvpn set meshnet on

# Set nickname to BigAssBerryPi
nordvpn meshnet set nickname BigAssBerryPi

# Allow notififcations
nordvpn set notify on

# Make NordVPN autoconnect to a Norwegian VPN server
nordvpn set autoconnect on NO

# Disable quantum protection
nordvpn set pq off

# Disable lan-discovery. This setting must be turned on if peers routing through 
# this device should be able to accesss other devices on this devices's network
nordvpn set lan-discovery off

#  Use nordlynx based on WireGuard for improved performance
nordvpn set technology nordlynx

# You must explicitly grant permission for other devices to route through it.
nordvpn meshnet peer allow-exit-node set terje.innerdal@gmail.com

# Allow different devices to use this device as an exit-node
nordvpn meshnet peer routing allow Pixel
nordvpn meshnet peer routing allow Tab8
nordvpn meshnet peer routing allow DELLUbuntu
nordvpn meshnet peer routing allow HPMint
nordvpn meshnet peer routing allow sunndal
