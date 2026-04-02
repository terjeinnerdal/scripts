#! /usr/bin/bash

nordvpn set meshnet on
nordvpn set notify on
nordvpn set autoconnect on BigAssBerryPi
nordvpn set pq off
nordvpn set lan-discovery off
nordvpn set technology nordlynx

# Auto-accept files shared from peers
nordvpn meshnet peer fileshare allow hp
nordvpn meshnet peer auto-accept enable hp
nordvpn meshnet peer fileshare allow Pixel
nordvpn meshnet peer auto-accept enable Pixel
nordvpn meshnet peer fileshare allow Tab8
nordvpn meshnet peer auto-accept enable Tab8

