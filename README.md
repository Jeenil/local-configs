# local-configs

Cross-platform shell configurations and keyboard remapping setups for Windows and macOS.

## Installation

### WSL (Ubuntu)

This is a personal setup. The WSL script expects the owner's SSH key and private repositories (`secrets`), and it loads work-specific settings from `secrets/work/` only if that folder exists. To reuse it, replace the constants at the top of `bash/setup-wsl.sh` and the repository names it clones.

On a fresh WSL install, this repository can be private, so the script cannot be downloaded anonymously. Copy the SSH key from Windows, then clone this repository and run the script:

```bash
mkdir -p ~/.ssh
cp /mnt/c/Users/<windows-username>/.ssh/id_ed25519* ~/.ssh/
chmod 600 ~/.ssh/id_ed25519
ssh-keyscan github.com >> ~/.ssh/known_hosts
mkdir -p ~/repositories
git clone git@github.com:Jeenil/local-configs.git ~/repositories/local-configs
bash ~/repositories/local-configs/bash/setup-wsl.sh
```

The script clones the other repositories, decrypts the secrets, runs the optional work setup from the private `secrets` repository, and installs all tools. It clones the [Jeenil/configs](https://github.com/Jeenil/configs) fork on the branch named in `bash/setup-wsl.sh`. Open a new shell when it finishes.

The script commits to GitHub repositories with the GitHub no-reply email, because the `gc` command in the fork rejects other addresses.

### Windows

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
