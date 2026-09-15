# NordVPN Meshnet Utility Scripts

These scripts simplify managing NordVPN Meshnet peers, configuring devices as exit nodes or peers, and controlling connection states.

---

## Setup & Installation

You can copy these scripts to your local bin directory (`~/.local/bin`) to run them from anywhere:

```bash
./copy_scripts.sh
source ~/.bashrc
```

Once installed, all commands are globally available with a `nord_` prefix (e.g., `nord_login`).

---

## Available Commands

| Local File | Installed Global Command | Description |
| :--- | :--- | :--- |
| `login.sh` | `nord_login` | Authenticate with NordVPN using `$NORDVPN_TOKEN` or `access_token.txt`. |
| `logout.sh` | `nord_logout` | Log out of NordVPN. |
| `config.sh` | `nord_config` | Configure device as a peer (`--peer`) or exit node (`--exit-node`) using `peers.json`. |
| `connect.sh` | `nord_connect [country/peer]` | Connect to a VPN server (default: `NO`) or Meshnet peer. |
| `disconnect.sh` | `nord_disconnect` | Disconnect from the active VPN server. |
| `list_peers.sh` | `nord_list_peers` | List available Meshnet peers. |
| `set_nickname.sh` | `nord_set_nickname` | Set a local nickname for this device. |
| `status.sh` | `nord_status` | Show connection status and Meshnet details. |
| `reset.sh` | `nord_reset` | Reset NordVPN settings to defaults. |
| `nord_watchdog.sh` | — | Watchdog daemon monitoring daemon health, Meshnet state, and routing rules. |

---

## Usage Examples

### Configure Current Device as an Exit Node
Configure this machine to allow specific peers in `peers.json` to route traffic through it and access the local network:

```bash
# Using existing device nickname
./config.sh --exit-node

# Or specify a custom nickname
./config.sh --exit-node mesh-raspberry
```

### Configure Current Device as a Standard Peer
Configure standard Meshnet settings (filesharing and auto-accept for peers in `peers.json`):

```bash
./config.sh --peer [nickname]
```

### Connect to a Meshnet Peer or VPN
```bash
# Connect to default country (NO)
nord_connect

# Connect to a specific country or Meshnet peer
nord_connect mesh-raspberry
```

---

## Raspberry Pi Exit Node Setup

When configuring a device (such as a Raspberry Pi) as an exit node:
- Ensure kernel IP forwarding is enabled (`sudo sysctl -w net.ipv4.ip_forward=1`).
- Specific allowed peers are defined in `peers.json` under `allowed_for_routing` and `allowed_for_local`.
- *Note:* To route streaming traffic (e.g., Netflix, TV2 Play) through a remote Raspberry Pi exit node, the Pi must run a local DNS resolver (such as Pi-hole or AdGuard Home).
