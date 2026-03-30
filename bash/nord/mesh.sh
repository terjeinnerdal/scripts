#! /usr/bin/bash

nordvpn set meshnet on

# Set nickname
nordvpn meshnet peer remove dellnord
nordvpn meshnet set nickname dellnord

# Auto-accept files shared from peers
nordvpn meshnet peer fileshare allow hpnord
nordvpn meshnet peer auto-accept enable hpnord
