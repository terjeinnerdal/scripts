#! /usr/bin/bash

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

