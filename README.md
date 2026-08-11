# Scripts Repository

A curated collection of automation scripts, tools, and utility modules for **Bash**, **PowerShell**, and **Docker**.

---

## 🛠️ Repository Overview

```
.
├── .github/
│   └── workflows/
│       └── lint.yml             # GitHub Actions CI workflow (ShellCheck & PSScriptAnalyzer)
├── bash/
│   ├── AutoRemoveSnapd.sh       # Removes snapd and associated packages on Debian/Ubuntu
│   ├── countLines.sh            # Counts lines in a text file with line numbers
│   ├── import-kali.sh           # Imports Kali Linux package repositories and GPG keys
│   ├── docker/
│   │   └── compose.yaml         # Docker Compose setup
│   ├── encryption/
│   │   ├── encrypt_file.sh      # AES-256-CBC file encryption (OpenSSL + PBKDF2)
│   │   └── decrypt_file.sh      # AES-256-CBC file decryption (OpenSSL)
│   └── nord/                    # NordVPN Meshnet control scripts
│       ├── config.sh            # NordVPN configuration helper
│       ├── connect.sh           # Connects to NordVPN
│       ├── copy_scripts.sh      # Deployment helper script
│       ├── exit_node.sh         # Manages and sets Meshnet exit node routing
│       ├── list_peers.sh        # Lists Meshnet peers filtered by status
│       ├── login.sh             # Interactive NordVPN login
│       ├── logout.sh            # NordVPN logout
│       ├── nord_watchdog.sh     # NordVPN connection watchdog daemon
│       ├── reset.sh             # NordVPN settings reset
│       └── set_nickname.sh      # Sets peer nickname in Meshnet
└── PowerShell/
    ├── CreateFile.ps1           # Creates test files of a specified size
    ├── DeleteEmptyFolders.ps1   # Wrapper to delete empty subdirectories
    ├── DeleteFiles.ps1          # Safe file deletion with age filtering & -WhatIf dry-run
    ├── FindEmptySubDirectories.ps1 # Wrapper to find empty subdirectories
    ├── ManageEmptyFolders.ps1   # Primary script for listing and removing empty folders
    ├── ManageEmptyFolders.Function.ps1 # Reusable PowerShell function module
    └── NextPVR.ps1              # NextPVR media recorder helper
```

---

## 🚀 Usage Guide

### Bash Scripts (`bash/`)

#### 🔐 File Encryption & Decryption (`bash/encryption/`)
Encrypt and decrypt files using OpenSSL AES-256-CBC with PBKDF2 key derivation (100,000 iterations):

```bash
# Encrypt a file (prompts securely for passphrase)
./bash/encryption/encrypt_file.sh document.pdf

# Decrypt an encrypted file
./bash/encryption/decrypt_file.sh document.pdf.enc
```

#### 🌐 NordVPN Meshnet Tools (`bash/nord/`)
Manage NordVPN connections and Meshnet exit nodes:

```bash
# List online Meshnet peers
./bash/nord/list_peers.sh online

# Configure an exit node
./bash/nord/exit_node.sh

# Run watchdog daemon to monitor and maintain VPN connectivity
./bash/nord/nord_watchdog.sh
```

---

### PowerShell Scripts (`PowerShell/`)

#### 📁 Empty Folder Cleanup (`PowerShell/ManageEmptyFolders.ps1`)
Find or delete empty folder hierarchies (deepest nested folders deleted first):

```powershell
# List all empty subdirectories under a path
.\PowerShell\ManageEmptyFolders.ps1 -Path "C:\Data"

# Delete empty subdirectories safely with confirmation
.\PowerShell\ManageEmptyFolders.ps1 -Path "C:\Data" -Delete

# Dry-run deletion using -WhatIf
.\PowerShell\ManageEmptyFolders.ps1 -Path "C:\Data" -Delete -WhatIf
```

#### 🧹 Safe File Cleanup (`PowerShell/DeleteFiles.ps1`)
Remove files matching a filter pattern and age threshold:

```powershell
# Delete .log files older than 30 days under C:\Logs (dry-run mode)
.\PowerShell\DeleteFiles.ps1 -Path "C:\Logs" -Filter "*.log" -DaysOld 30 -Recurse -WhatIf
```

---

## 🤖 Code Quality & CI

This repository uses [GitHub Actions](file:///.github/workflows/lint.yml) to ensure code quality on every push and pull request:
- **ShellCheck**: Static analysis for all `.sh` scripts.
- **PSScriptAnalyzer**: Best-practice rules for `.ps1` scripts.
