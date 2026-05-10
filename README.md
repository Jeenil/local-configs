# local-configs

Cross-platform shell configurations and keyboard remapping setups for Windows and macOS.

## Installation

Clone the repo and run the setup script to copy everything to the right places:

```powershell
git clone https://github.com/Jeenil/local-configs.git
cd local-configs
.\setup.ps1
```

Before running, make sure [AutoHotkey v2](https://www.autohotkey.com/) and [VSCodium](https://vscodium.com/) are installed, and that PowerShell allows scripts:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Contents

- **`bash/`** — Git Bash profile that loads shell config from [Jeenil/configs](https://github.com/Jeenil/configs), plus local PATH and alias overrides
- **`PowerShell/`** — PowerShell profile with Git, kubectl, Terraform, and package manager aliases
- **`AutoHotkey/`** — Windows keyboard remapping and app-launch shortcuts
- **`VSCodium/`** — Global editor settings for the notes workflow
- **`karabiner/`** — Karabiner-Elements config for macOS keyboard remapping

## Related

- [Jeenil/configs](https://github.com/Jeenil/configs) — Bash configs sourced by the `.bash_profile` here
- [sillydodo.net](https://sillydodo.net) — Personal portfolio
