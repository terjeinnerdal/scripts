#!/usr/bin/env bash

TOKEN="${1:-${NORDVPN_TOKEN:-}}"

if [[ -z "$TOKEN" ]]; then
    read -rsp "Enter NordVPN access token: " TOKEN
    echo
fi

if [[ -z "$TOKEN" ]]; then
    echo "Error: NordVPN token cannot be empty." >&2
    exit 1
fi

nordvpn login --token "$TOKEN"
