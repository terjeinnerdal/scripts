## Quick guide for AI coding agents working in this repo

This repository is PowerShell-first: small, self-contained scripts and reusable functions live under `PowerShell/`. Aim for minimal, reversible edits and preserve the existing scripting conventions.

Key patterns (use these exactly where applicable):
- Functions use `[CmdletBinding(SupportsShouldProcess=$true)]` and `Param()` with typed parameters. Example: `PowerShell/ManageEmptyFolders.Function.ps1`.
- Top-level scripts are thin wrappers around reusable logic and typically call `ShouldProcess()` and honor `-WhatIf`/`-Confirm`. Example: `PowerShell/ManageEmptyFolders.ps1`.
- Validate paths with `Test-Path -PathType Container` before acting.
- Prefer `Remove-Item -LiteralPath` for deletions and sort folders by `FullName.Length` descending to delete deepest-first.
- Use `Write-Verbose`, `Write-Error`, `Write-Host` for CLI-friendly output but return objects from functions where practical (functions return folder objects in `ManageEmptyFolders.Function.ps1`).

Developer workflows and verification (no CI/build system):
- Run scripts with PowerShell Core (pwsh) on Linux or Windows. Example run (dry-run delete):

```bash
pwsh -noprofile -File ./PowerShell/ManageEmptyFolders.ps1 -Path /some/path -Delete -WhatIf
```

- To load and inspect a function without executing script logic (useful for static checks):

```bash
pwsh -noprofile -Command ". ./PowerShell/ManageEmptyFolders.Function.ps1; Get-Command ManageEmptyFolders"
```

- There are no automated tests; keep changes small and verify by running scripts in `-WhatIf` or `-Verbose` mode.

Project-specific conventions and examples:
- File naming: function file names use camel-case and `.Function.ps1` suffix when they declare reusable functions (e.g., `ManageEmptyFolders.Function.ps1`). The script wrapper mirrors the function name (e.g., `ManageEmptyFolders.ps1`).
- Parameter style: use named parameters with attributes like `Mandatory`, `Position`, and `HelpMessage`. Keep parameter names descriptive and follow existing hyphenation/capitalization.
- Safety: any destructive change must honor `SupportsShouldProcess` and call `$PSCmdlet.ShouldProcess()` before `Remove-Item`.
- Return types: functions should return objects (not only Write-Host) so they can be composed and tested.

Integration points and external dependencies:
- Docker: `PowerShell/NextPVR.ps1` demonstrates running a Docker container for NextPVR. When editing container-related scripts, use the Docker CLI and preserve existing volume and port mappings.
- No external modules or package managers are required by the repo. Avoid adding dependencies unless explicitly requested.

Quick checklist for PRs made by an AI:
1. Keep changes minimal and focused to a single script or function.
2. Preserve help comment blocks (.SYNOPSIS/.DESCRIPTION/.PARAMETER/.EXAMPLE) when editing PowerShell files.
3. Ensure path checks (`Test-Path -PathType Container`) exist before remove operations.
4. Use `-WhatIf` and `-Verbose` to test destructive flows and include example commands in the PR description.

Files to inspect first (high signal):
- `PowerShell/ManageEmptyFolders.Function.ps1` — canonical CmdletBinding + safe delete pattern.
- `PowerShell/ManageEmptyFolders.ps1` — wrapper script showing user-facing CLI behavior.
- `PowerShell/NextPVR.ps1` — Docker-run example.
- `PowerShell/*.ps1` — inspect other scripts for consistent parameter and safety patterns.

If anything is unclear or you need deeper conventions (naming rules, target PowerShell version, or preferred logging/telemetry), ask the maintainer for clarification. I can iterate on examples or expand this file on request.
