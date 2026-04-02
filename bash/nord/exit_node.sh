#! /usr/bin/bash

# This script lets other peers route through the RaspberryPI

nordvpn set meshnet on
nordvpn meshnet set nickname BigAssBerryPI

# Other meshnet peers will not be able to access local network devices
nordvpn set lan-discovery off

#nordvpn meshnet peer routing allow S22
#nordvpn meshnet peer routing allow Tab8
nordvpn meshnet peer routing allow pi-dell
#nordvpn meshnet peer routing allow HPMint
#nordvpn meshnet peer routing allow sunndal
nordvpn meshnet peer routing allow Pixel

# You must explicitly grant permission for other devices to route through it.
# nordvpn meshnet peer allow-exit-node set terje.innerdal@protonmail.com
