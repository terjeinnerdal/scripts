#! /usr/bin/bash

nordvpn set meshnet on

nordvpn set lan-discovery off

nordvpn meshnet set nickname BigAssBerryPI

#nordvpn meshnet peer routing allow S22
#nordvpn meshnet peer routing allow Tab8
nordvpn meshnet peer routing allow mesh-dell
#nordvpn meshnet peer routing allow HPMint
#nordvpn meshnet peer routing allow sunndal
nordvpn meshnet peer routing allow Pixel

# You must explicitly grant permission for other devices to route through it.
nordvpn meshnet peer allow-exit-node set terje.innerdal@protonmail.com