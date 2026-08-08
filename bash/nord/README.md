# NordVPN Meshnet Utility Scripts

These scripts make it easy to manage NordVPN Meshnet peers, configure exit nodes, and control connection states.

## Setup & Installation

You can copy these scripts to your local bin directory to run them from anywhere:

```bash
./copy_scripts.sh
source ~/.bashrc
```

Once installed, all commands are globally available with a `nord_` prefix (e.g. `nord_login`).

## Available Commands

| Local File | Installed Global Command | Description |
| :--- | :--- | :--- |
| `login.sh` | `nord_login` | Authenticate with NordVPN |
| `logout.sh` | `nord_logout` | Log out of NordVPN |
| `config.sh` | `nord_config` | Configure NordVPN routing and settings |
| `connect.sh` | `nord_connect <peer>` | Connect to a Meshnet peer |
| `exit_node.sh` | `nord_exit_node <peer>` | Set a peer as your exit node |
| `list_peers.sh` | `nord_list_peers` | List available Meshnet peers |
| `set_nickname.sh` | `nord_set_nickname` | Set a local nickname for the device |
| `reset.sh` | `nord_reset` | Reset NordVPN settings to defaults |

## Setup Examples

### Set Exit Node

```bash
nord_exit_node mesh-raspberry
```

### Connect to Peer

```bash
nord_connect mesh-dell
```

## Peer Names

The following peer names are configured/referenced:

- `mesh-hp`
- `mesh-dell`
- `mesh-tab8`
- `mesh-pixel`
- `mesh-raspberry`
- `mesh-sunndal`

## RaspberryPi Routing / Exit Node Setup

The Raspberry Pi will be configured to act as an exit-node for other Meshnet peers. Other peers using the Raspberry Pi for routing also gives them permission to access local devices like printers, cameras, and other LAN-connected devices.

The ultimate goal is to install this Raspberry Pi at a remote location (e.g., family home) so that you can connect to local streaming services (Netflix, TV2 Play, etc.) from other locations.

*Note:* If you want to route streaming traffic through a remote Raspberry Pi, the Pi itself must run a DNS server (like Pi-hole or AdGuard Home) that your Meshnet devices can route traffic through.
