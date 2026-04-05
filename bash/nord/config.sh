#! /usr/bin/bash

if [ -z "$1" ]; then
    echo "Error: No argument provided."
    exit 1
fi

echo "The argument is: $1"

NICKNAME=$1

nordvpn set meshnet on
nordvpn meshnet set nickname $NICKNAME

nordvpn set notify on

nordvpn set pq off
nordvpn set lan-discovery off
nordvpn set technology nordlynx

# Set auto-connect for these devices
nordvpn set autoconnect on mesh-raspberry
nordvpn set autoconnect on mesh-hp
nordvpn set autoconnect on mesh-dell
nordvpn set autoconnect on mesh-tab8
nordvpn set autoconnect on mesh-pixel

# Auto-accept files shared from peers
nordvpn meshnet peer fileshare allow mesh-hp
nordvpn meshnet peer auto-accept enable mesh-hp
nordvpn meshnet peer fileshare allow mesh-dell
nordvpn meshnet peer auto-accept enable mesh-dell
nordvpn meshnet peer fileshare allow mesh-pixel
nordvpn meshnet peer auto-accept enable mesh-pixel
nordvpn meshnet peer fileshare allow mesh-tab8
nordvpn meshnet peer auto-accept enable mesh-tab8
nordvpn meshnet peer fileshare allow mesh-raspberry
nordvpn meshnet peer auto-accept enable mesh-raspberry
