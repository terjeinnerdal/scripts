#! /usr/bin/bash

if [ -z "$1" ]; then
   echo "Pass the nickname for the device"
   exit 1
fi

nordvpn meshnet set nickname "$1"
