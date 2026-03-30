#! /usr/bin/bash

if [ -v "$1" ]; then
   echo "Pass the nickname for the device"
   exit
fi

nordvpn meshnet set nickname BigAssBerryPI

