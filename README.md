# local-configs

Cross-platform shell configurations and keyboard remapping setups. Designed to keep a consistent, productive workflow across machines.

---

## Quick Start

Clone and run the setup script — it copies everything to the right places:

```powershell
git clone https://github.com/Jeenil/local-configs.git
cd local-configs
.\setup.ps1
```

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

See [`PowerShell/README.md`](./PowerShell/README.md) for full command reference.

→ Live location: `$PROFILE`

### [`AutoHotkey/`](./AutoHotkey/)

Windows keyboard remapping and automation scripts using [AutoHotkey v2](https://www.autohotkey.com/).

- `main.ahk` — Core hotkeys: window cycling (`Win+Tab`), window minimize (`Win+Down`), reload/suspend toggles, app-launch shortcuts (`Ctrl+1` → Terminal, `Ctrl+2` → VS Code, `Ctrl+3` → VSCodium (notes), `Ctrl+4` → Chrome, ...)

→ Live location: `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\`

### [`VSCodium/`](./VSCodium/)

Global [VSCodium](https://vscodium.com/) user settings — used for the notes-only workflow (`Ctrl+3`).

- `settings.json` — Base editor settings. Notes-repo-specific overrides (GitDoc, markdown format on save) live in [`notes/.vscode/settings.json`](https://github.com/Jeenil/notes/blob/main/.vscode/settings.json) and inherit from this.

→ Live location: `%APPDATA%\Codium\User\settings.json`

### [`karabiner/`](./karabiner/)

[Karabiner-Elements](https://karabiner-elements.pqrs.org/) config for macOS keyboard remapping.

- `karabiner.json` — App-launch shortcuts (`Cmd+1` → iTerm, `Cmd+2` → VS Code, etc.)

→ Live location: `~/.config/karabiner/karabiner.json`

---

## Prerequisites

Before running `setup.ps1`, make sure these are installed:

- [AutoHotkey v2](https://www.autohotkey.com/)
- [VSCodium](https://vscodium.com/)
- PowerShell execution policy set to allow scripts:
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

---

## Related

- [sillydodo.net](https://sillydodo.net) — Personal portfolio
