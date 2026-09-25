#!/usr/bin/env bash

# Copies scripts to the ~/.local/bin/ folder so they can be executed 
# everywhere.
# Run source ~/.bashrc after running this script to make the new scripts 
# available. 
# If the ~/.local/bin/ directory isn't there you need to create it. 
# Then you need to add it to the PATH by inserting the line 
# export PATH="$PATH" + ",~/home/terje/.local/bin to the end of the 
# ~/.bashrc file.
#
# All copied files will have nord_ prepended and the .sh removed in the new 
# filename.
cp nord_access_token.txt ~/.local/bin/nord_access_token.txt
cp config.sh ~/.local/bin/nord_config
cp connect.sh ~/.local/bin/nord_connect
cp exit_node.sh ~/.local/bin/nord_exit_node
cp list_peers.sh ~/.local/bin/nord_list_peers
cp login.sh ~/.local/bin/nord_login
cp logout.sh ~/.local/bin/nord_logout
# cp nord_watchdog.sh ~/.local/bin/nord_watchdog
cp reset.sh ~/.local/bin/nord_reset
cp set_nickname.sh ~/.local/bin/nord_set_nickname
cp disconnect.sh ~/.local/bin/nord_disconnect
cp status.sh ~/.local/bin/nord_status
cp  .sh ~/.local/bin/nord_status
cp  .sh ~/.local/bin/nord_status



