# Repository Instructions: Scripts

This repository contains utility, automation, and infrastructure scripts across **PowerShell**, **Bash**, and **Docker**. It is designed for cross-platform system administration, network configuration, and service deployment.

---

## Directory Overview

- **`PowerShell/`**: PowerShell scripts (`.ps1`) and reusable functions (`*.Function.ps1`). Primarily handles file/folder management, directory cleanup, and container launch helpers.
- **`bash/`**: Shell automation scripts:
  - **`nord/`**: NordVPN Meshnet and exit node configuration, peer management, connection toggles, and watchdog daemon scripts.
  - **`docker/`**: Container orchestration via Docker Compose (`compose.yaml`) for database and administrative tooling.
  - **`encryption/`**: File encryption and decryption utilities.
  - **Root `bash/` scripts**: System maintenance (e.g., snap removal, Kali disk image importing, text processing).
- **`.github/`**: Project guidelines and AI assistant instructions (`copilot-instructions.md`).

---

## Scripting Guidelines & Conventions

### 1. PowerShell (`.ps1`, `*.Function.ps1`)

- **Environment**: Target PowerShell Core (`pwsh`) for cross-platform compatibility where possible, while supporting Windows PowerShell where native APIs are required.
- **Function vs. Wrapper Architecture**:
  - Reusable logic belongs in `*.Function.ps1` files (e.g., `ManageEmptyFolders.Function.ps1`). Functions should return objects to the pipeline rather than solely printing formatted text.
  - User-facing scripts (e.g., `ManageEmptyFolders.ps1`) act as thin CLI wrappers around functions and provide interactive or command-line feedback.
- **Cmdlet Binding & Parameters**:
  - Reusable functions and scripts performing actions must declare `[CmdletBinding(SupportsShouldProcess=$true)]` and a typed `Param()` block.
  - Use explicit parameter attributes: `[Parameter(Mandatory=$true, Position=0, HelpMessage="...")]`.
  - Provide comment-based help blocks (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`).
- **Safety First**:
  - Any destructive operation (such as `Remove-Item`) must honor `SupportsShouldProcess` by calling `$PSCmdlet.ShouldProcess(...)` to support `-WhatIf` and `-Confirm`.
  - Validate paths using `Test-Path -Path $Path -PathType Container` (or `Leaf`) before executing operations.
  - Use `-LiteralPath` with `Remove-Item` and `Get-ChildItem` to avoid unintended wildcard expansion.
  - When deleting nested directories recursively, sort by path length descending (`Sort-Object { $_.FullName.Length } -Descending`) to ensure deepest children are deleted first.
- **Output & Diagnostics**:
  - Use `Write-Verbose` for operational details.
  - Use `Write-Error` or `throw` for failures; avoid abruptly terminating sessions using `exit` within functions (use `return` instead).

### 2. Bash (`.sh`)

- **Shebang**: Use `#!/usr/bin/env bash` (or `#!/usr/bin/bash`).
- **Error Handling**: For automation and multi-step scripts, enforce strict mode:
  ```bash
  set -euo pipefail
  ```
- **Dependency & Argument Validation**:
  - Check required tools before proceeding (e.g., `command -v jq >/dev/null 2>&1 || { ... }`).
  - Validate positional arguments (`$#`, `$1`) and provide helpful error messages.
  - Provide a `display_help()` or `-h`/`--help` flag for CLI scripts.
- **Safe File & Temp Directory Handling**:
  - Always quote variable expansions (e.g., `"$FILE"`, `"$DEST_DIR"`).
  - Use `mktemp -d` for temporary scratch space and ensure cleanup using traps:
    ```bash
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT
    ```
- **Linting**: All Bash scripts should adhere to POSIX / ShellCheck best practices and pass `shellcheck` with zero warnings.

### 3. Docker & Container Orchestration

- **Docker Compose (`compose.yaml`)**:
  - Follow the standard Compose specification (`services`, `networks`, `volumes`).
  - Restrict exposed service ports to `127.0.0.1:<port>:<port>` unless external LAN access is explicitly intended.
  - Never hardcode sensitive passwords or tokens; use environment variable interpolation with fallback guards (e.g., `${POSTGRES_PASSWORD:?POSTGRES_PASSWORD must be set}`) and local `.env` files.
- **Direct Container Execution (`docker run`)**:
  - When wrapping `docker run` in PowerShell or Bash scripts, specify explicit container names (`--name`), detached mode (`-d`), explicit restart policies (`--restart unless-stopped`), and volume bindings.
- **Container Cleanup**:
  - Ensure scripts that spin up temporary or test containers cleanly stop and prune them on exit.

---

## Security & Secrets Management

- **No Committed Secrets**: Never commit access tokens, private keys, `.env` files, or cleartext passwords.
- **Ignored Sensitive Files**: Verify that files containing credentials (e.g., `bash/docker/.env`, `bash/nord/access_token.txt`) are covered by `.gitignore`.
- **Environment Variables**: Prefer reading authentication tokens and credentials from environment variables (e.g., `$NORDVPN_TOKEN`) before falling back to local ignored configuration files.

---

## Developer Workflows & Verification

### PowerShell Verification
```bash
# Dry run script execution with -WhatIf and -Verbose
pwsh -noprofile -File ./PowerShell/ManageEmptyFolders.ps1 -Path /target/path -Delete -WhatIf -Verbose

# Syntax and function definition check
pwsh -noprofile -Command ". ./PowerShell/ManageEmptyFolders.Function.ps1; Get-Command ManageEmptyFolders"
```

### Bash Verification
```bash
# Check bash syntax without executing
bash -n ./bash/<script>.sh

# Run ShellCheck static analysis
shellcheck ./bash/<script>.sh
```

### Docker Verification
```bash
# Validate Docker Compose file syntax and resolved environment variables
docker compose -f ./bash/docker/compose.yaml config
```

---

## Guidelines for AI Assistants

1. **Keep Changes Minimal**: Scope edits strictly to the requested script or utility.
2. **Preserve Documentation**: Maintain existing comment-based help headers, docstrings, and inline comments.
3. **Ensure Reversibility & Safety**: Always test destructive commands with `-WhatIf` / dry-run logic and path verification.
4. **Follow Established Patterns**: Match the parameter conventions and naming styles already present in sibling scripts.
