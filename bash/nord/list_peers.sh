#! /usr/bin/bash

filter=${1:-online}

echo $filter

nordvpn mesh peer list --filter=$filter
