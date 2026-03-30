#! /usr/bin/bash

# Assign the NO country code if there is no argument
country=${1:-NO}

echo "Connecting to country code $country"
nordvpn connect "$country"
