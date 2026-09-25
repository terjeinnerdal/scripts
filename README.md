# System Automation & Administration Scripts

A collection of utility, automation, network management, and infrastructure scripts written in **PowerShell**, **Bash**, and orchestrated with **Docker**. Built for cross-platform system administration across Linux and Windows environments.

---

## Table of Contents

- [Directory Overview](#directory-overview)
- [PowerShell Utilities](#powershell-utilities)
- [Bash Automation & Maintenance](#bash-automation--maintenance)
  - [NordVPN Meshnet Management](#nordvpn-meshnet-management)
  - [System Utilities & Virtualization](#system-utilities--virtualization)
- [Docker Services](#docker-services)
- [Installation & Getting Started](#installation--getting-started)
- [Security & Environment Variables](#security--environment-variables)
- [Development & Conventions](#development--conventions)

---

## Directory Overview

```text
.
├── PowerShell/          # PowerShell Core / Windows PowerShell scripts and reusable functions
│   ├── ManageEmptyFolders.ps1
│   ├── ManageEmptyFolders.Function.ps1
│   ├── DeleteEmptyFolders.ps1
│   ├── FindEmptySubDirectories.ps1
│   ├── CreateFile.ps1
│   └── NextPVR.ps1
├── bash/                # Bash automation, maintenance, and container orchestration
│   ├── docker/          # Docker Compose stack definitions
│   │   └── compose.yaml
│   ├── encryption/      # File encryption and decryption helpers
│   ├── nord/            # NordVPN Meshnet, exit node routing, and watchdog daemon
│   ├── AutoRemoveSnapd.sh
│   ├── countLines.sh
│   └── import-kali.sh
├── .github/             # AI assistant and agent instructions
├── GEMINI.md            # Repository guidelines and workspace rules
└── README.md
```

---

## PowerShell Utilities

The scripts located in [`PowerShell/`](PowerShell/) target PowerShell Core (`pwsh`) for cross-platform compatibility while supporting Windows PowerShell where native APIs are required.

- **`ManageEmptyFolders.ps1` / `ManageEmptyFolders.Function.ps1`**:
  Recursively searches a directory tree for empty folders (containing no files or subfolders).
  - Lists empty paths by default.
  - Safely deletes empty folders deepest-first when passed `-Delete`.
  - Supports `-WhatIf`, `-Confirm`, and `-Verbose` via `[CmdletBinding(SupportsShouldProcess=$true)]`.
- **`FindEmptySubDirectories.ps1`**:
  Recursively scans and outputs the paths of all empty subdirectories under a given root path.
- **`DeleteEmptyFolders.ps1`**:
  Recursively locates and deletes empty directories under the target path.
- **`CreateFile.ps1`**:
  Safely creates a new file at the specified path if it does not already exist.
- **`NextPVR.ps1`**:
  Spins up a NextPVR personal video recorder Docker container with host volume mounts and published ports (`8866`, `16891/udp`).

### PowerShell Usage Example

```powershell
# Preview empty folders to delete (dry run)
pwsh -noprofile -File ./PowerShell/ManageEmptyFolders.ps1 -Path "/path/to/target" -Delete -WhatIf -Verbose

# Delete empty folders
pwsh -noprofile -File ./PowerShell/ManageEmptyFolders.ps1 -Path "/path/to/target" -Delete
```

---

## Bash Automation & Maintenance

All Bash scripts in [`bash/`](bash/) are designed for Linux environments and enforce strict error handling (`set -euo pipefail`).

### NordVPN Meshnet Management

The [`bash/nord/`](bash/nord/) directory contains scripts to automate NordVPN Meshnet configuration, peer routing, and exit node administration:

| Script | Installed Command (`~/.local/bin/`) | Description |
| :--- | :--- | :--- |
| `login.sh` | `nord_login` | Authenticates using `$NORDVPN_TOKEN` or `access_token.txt`. |
| `logout.sh` | `nord_logout` | Logs out of the current NordVPN session. |
| `config.sh` | `nord_config` | Configures Meshnet mode (`--peer` or `--exit-node`) and applies peer permissions from `peers.json`. |
| `connect.sh` | `nord_connect [country/peer]` | Connects to a VPN server (defaults to Norway / `NO`) or Meshnet peer. |
| `disconnect.sh` | `nord_disconnect` | Disconnects from the active VPN server. |
| `list_peers.sh` | `nord_list_peers` | Lists all accessible Meshnet peers. |
| `set_nickname.sh` | `nord_set_nickname` | Assigns a local Meshnet nickname to the device. |
| `status.sh` | `nord_status` | Displays NordVPN connection and Meshnet status. |
| `reset.sh` | `nord_reset` | Reconnects NordVPN (logs out, logs in, and reconnects). |
| `nord_watchdog.sh` | `nord_watchdog` | Daemon script to monitor daemon health, Meshnet state, IP forwarding, and peer routing permissions. |
| `copy_scripts.sh` | — | Copies all Nord scripts to `~/.local/bin/` with the `nord_` prefix. |

#### Global Command Installation

```bash
cd bash/nord
./copy_scripts.sh
source ~/.bashrc
```

### System Utilities & Virtualization

- **`AutoRemoveSnapd.sh`**: Purges `snapd` and unneeded dependencies on Debian/Ubuntu systems.
- **`import-kali.sh`**: Extracts a Kali Linux QEMU `.7z` archive into `/var/lib/libvirt/images/`, moves the extracted `.qcow2` image, and applies `root:libvirt-qemu` ownership with `660` permissions.
- **`countLines.sh`**: Reads an input file line by line, printing line indices and total line count.

---

## Docker Services

The [`bash/docker/`](bash/docker/) directory hosts multi-container service configurations via Docker Compose.

- **`compose.yaml`**:
  - **`db`**: PostgreSQL container (`postgres:latest`) configured for the `PillCulator` database.
  - **`adminer`**: Web-based database management interface (`adminer:latest`) exposed on `127.0.0.1:8080`.
  - **Security**: Service ports are bound strictly to `127.0.0.1` by default to prevent unwanted external network exposure.

### Running the Stack

```bash
# Set database password and run in background
export POSTGRES_PASSWORD="your_secure_password"
docker compose -f bash/docker/compose.yaml up -d

# Verify configuration syntax
docker compose -f bash/docker/compose.yaml config
```

---

## Installation & Getting Started

### Prerequisites

Depending on which scripts you run, ensure the following tools are installed:

- **PowerShell**: PowerShell Core (`pwsh`) v7+
- **Bash**: GNU Bash 4.4+
- **Docker**: Docker Engine and Docker Compose v2+
- **Utilities**: `jq` (JSON parsing for Meshnet), `p7zip-full` (for Kali import), `nordvpn` CLI

---

## Security & Environment Variables

- **No Committed Secrets**: Never commit access tokens, private keys, or `.env` files.
- **Gitignored Files**:
  - `bash/docker/.env`: Local environment file for Docker database passwords.
  - `bash/nord/access_token.txt`: Local NordVPN login token.
- **Environment Variables**:
  - `$NORDVPN_TOKEN`: Preferred token variable for `bash/nord/login.sh`.
  - `$POSTGRES_PASSWORD`: Required password for `bash/docker/compose.yaml`.

---

## Development & Conventions

For detailed coding guidelines, naming conventions, and AI agent instructions, consult [`GEMINI.md`](GEMINI.md) and [`.github/copilot-instructions.md`](.github/copilot-instructions.md).

- **Bash**: Validate all scripts using `shellcheck` and verify syntax with `bash -n <script>.sh`.
- **PowerShell**: Ensure destructive functions support `ShouldProcess` and use `-LiteralPath`.
