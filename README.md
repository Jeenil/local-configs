# local-configs

Cross-platform shell configurations and keyboard remapping setups. Designed to keep a consistent, productive workflow across machines.

---

## Contents

### [`PowerShell/`](./PowerShell/)

PowerShell profile with a full suite of shell aliases and automation — mirroring a Bash workflow on Windows.

Highlights:
- **Git workflow**: branch management, commit helpers, rebase/squash shortcuts (`gb`, `gc`, `gp`, `grb`, `gsq`, ...)
- **kubectl**: `k`, `kgp`, `kdd`, `kdp`, `kgd`, `kds`
- **Package manager**: auto-detects npm/yarn/pnpm/bun — `b` (build), `d` (dev), `t` (test), `l` (lint)
- **Pulumi**: `pd`, `pp`, `pu`, `puy`
- **Terraform**: `ta`, `taa`, `tc`, `td`, `tf`, `ti`, `tp`, `tv`
- **Auto git config**: sets sane defaults (rebase on pull, prune on fetch, etc.)
- **Custom prompt**: shows username, directory, and git branch
- **Remote loading**: bootstrap script pulls latest config from GitHub on every shell start

See [`PowerShell/README.md`](./PowerShell/README.md) for full setup instructions and command reference.

### [`AutoHotkey/`](./AutoHotkey/)

Windows keyboard remapping and automation scripts using [AutoHotkey v2](https://www.autohotkey.com/).

- `main.ahk` — Core hotkeys: window cycling (`Win+Tab`), window minimize (`Win+Down`), reload/suspend toggles, app-launch shortcuts (`Ctrl+1` → Terminal, `Ctrl+2` → VS Code, `Ctrl+3` → VSCodium (notes), `Ctrl+4` → Chrome, ...)

### [`VSCodium/`](./VSCodium/)

Global [VSCodium](https://vscodium.com/) user settings — used for the notes-only workflow.

- `settings.json` → `%APPDATA%\Codium\User\settings.json`

Notes-repo-specific overrides (GitDoc enabled, markdown format on save) live in the notes repo at `.vscode/settings.json` and inherit from this base.

### [`karabiner/`](./karabiner/)

[Karabiner-Elements](https://karabiner-elements.pqrs.org/) config for macOS keyboard remapping.

- `karabiner.json` — App-launch shortcuts (`Cmd+1` → iTerm, `Cmd+2` → VS Code, etc.)

---

## Setup

### PowerShell (Windows)

```powershell
# 1. Find your profile path
$PROFILE

# 2. Copy PowerShell_profile.ps1 content to that location
#    It will auto-download profile_remote.ps1 from GitHub on startup

# 3. Set execution policy if needed (run as Administrator)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### AutoHotkey (Windows)

1. Install [AutoHotkey v2](https://www.autohotkey.com/)
2. Copy or symlink `AutoHotkey/main.ahk` to your startup folder
3. Run `main.ahk`

### VSCodium (Windows)

```powershell
Copy-Item VSCodium\settings.json "$env:APPDATA\Codium\User\settings.json"
```

### Karabiner (macOS)

1. Install [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
2. Copy `karabiner/karabiner.json` to `~/.config/karabiner/karabiner.json`

---

## Related

- [sillydodo.net](https://sillydodo.net) — Personal portfolio
