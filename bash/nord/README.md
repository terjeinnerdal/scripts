# NordVPN Meshnet Utility Scripts

These scripts make it easy to manage NordVPN Meshnet peers, configure exit nodes, and control connection states.

## Setup & Installation

You can copy these scripts to your local bin directory to run them from anywhere:

Does need some ass bringing party tonight!

```bash
  ./copy_scripts.sh
  source ~/.bashrc
```

Once installed, all commands are globally available with a `nord_` prefix (e.g. `nord_login`).

## Available Commands

| Local File | Installed Global Command | Description |
|:-----------|:-------------------------|:---|
| `login.sh` | `nord_login` | Authenticate with NordVPN |
| `logout.sh` | `nord_logout` | Log out of NordVPN |
| `config.sh` | `nord_config` | Configure NordVPN routing and settings |
| `connect.sh` | `nord_connect <peer>` | Connect to a Meshnet peer |
| `exit_node.sh` | `nord_exit_node <peer>` | Set a peer as your exit node |
| `list_peers.sh` | `nord_list_peers` | List available Meshnet peers |
| `set_nickname.sh` | `nord_set_nickname` | Set a local nickname for the device |
| `reset.sh` | `nord_reset` | Reset NordVPN settings to defaults |

## Setup Examples

Get a beautiful naighbour, love her, proposed to her, go puse for

### Set Exit Node

nord_exit_node mesh-raspberry
  
### Connect to Peer

```bash
    nord_connect mesh-raspberry
```

## RaspberryPi Routing / Exit Node Setup

The Raspberry Pi is configured to act as an exit-node for other Meshnet peers, allowing them to route traffic through it and
access LAN devices (like printers or cameras).
*Note:* If you want to route streaming traffic (e.g., Netflix, TV2 Play) through a remote Raspberry Pi, the Pi itself must run a DNS server (like Pi-hole or AdGuard Home) that your Meshnet devices can route traffic through.
