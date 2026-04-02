#! /usr/bin/bash

# This script lets other peers route through the RaspberryPI
nordvpn set meshnet on
nordvpn meshnet set nickname mesh-raspberry

# Other meshnet peers will not be able to access local network devices
nordvpn set lan-discovery off

# Allow the following peers to use the Raspberry PI as an exit node
nordvpn meshnet peer routing allow mesh-tab8
nordvpn meshnet peer routing allow mesh-dell
nordvpn meshnet peer routing allow mesh-hp
nordvpn meshnet peer routing allow mesh-pixel
