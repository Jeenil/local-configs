# Personal Configuration Files

Cross-platform shell configurations, keyboard shortcuts, and productivity tools.

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/configs.git
cd configs

# Run the installer for your platform
# On Mac/Linux:
./install.sh

# On Windows (PowerShell):
.\install.ps1
```

## What's Included

### Shell Configurations

- **PowerShell** (`PowerShell/profile.ps1`) - Universal profile for PowerShell 5 & 7, works on Windows, Mac, and Linux
- **Bash** (`bash/.bash_profile`) - Mac/Linux bash configuration, inherits from [Zamiell's configs](https://github.com/Zamiell/configs)

### Keyboard Shortcuts

- **Windows** (`AutoHotkey/main.ahk`) - Application launchers and window management
- **Mac** (`karabiner.json`) - Equivalent shortcuts using Karabiner-Elements

### Keyboard Shortcut Mappings

| Shortcut | Windows (Ctrl+) | Mac (Cmd+) | Application                         |
| -------- | --------------- | ---------- | ----------------------------------- |
| 1        | Ctrl+1          | Cmd+1      | Terminal (Windows Terminal / iTerm) |
| 2        | Ctrl+2          | Cmd+2      | VS Code                             |
| 3        | Ctrl+3          | Cmd+3      | Obsidian                            |
| 4        | Ctrl+4          | Cmd+4      | Chrome                              |
| 5        | Ctrl+5          | Cmd+5      | Edge                                |
| 6        | Ctrl+6          | Cmd+6      | Notepad++ (Windows only)            |

**Additional Windows Shortcuts (AutoHotkey):**

- `Win+Down` - Minimize active window
- `Win+Tab` - Cycle forward through windows of same application
- `Win+Shift+Tab` - Cycle backward through windows of same application
- `Ctrl+Shift+Alt+R` - Reload AutoHotkey script
- `Ctrl+Shift+Alt+S` - Suspend/resume AutoHotkey

## Command Reference

### Navigation Shortcuts

| Command     | Description                  |
| ----------- | ---------------------------- |
| `r`         | Go to repositories directory |
| `..`        | Go up one directory          |
| `...`       | Go up two directories        |
| `~`         | Go to home directory         |
| `desktop`   | Go to Desktop                |
| `downloads` | Go to Downloads              |
| `docs`      | Go to Documents              |

### Git Commands - Basic

| Command     | Description                              |
| ----------- | ---------------------------------------- |
| `gs`        | `git status --porcelain` (short status)  |
| `ga <file>` | `git add <file>`                         |
| `gaa`       | `git add --all`                          |
| `gc "msg"`  | Commit all changes with message and push |
| `gp`        | `git pull --rebase`                      |
| `gu`        | `git push`                               |
| `guf`       | `git push --force`                       |
| `gd`        | `git diff`                               |
| `gl`        | `git log`                                |
| `glg`       | `git log --graph` (pretty format)        |

### Git Commands - Branches

| Command     | Description                          |
| ----------- | ------------------------------------ |
| `gb desc`   | Create new branch with auto-naming   |
| `gbl`       | List branches with numbers           |
| `gsw 2`     | Switch to branch #2 from list        |
| `gswm`      | Switch to main + cleanup             |
| `gswc name` | Create and switch to new branch      |
| `gbd 2`     | Delete branch #2 (local + remote)    |
| `gbdl 2`    | Delete branch #2 (local only)        |
| `gbc`       | Clean merged/gone branches           |
| `gbs`       | Squash all commits on current branch |

### Git Commands - Advanced

| Command     | Description                            |
| ----------- | -------------------------------------- |
| `gpr`       | Create pull request                    |
| `gcs`       | Show last commit in browser            |
| `gcu`       | Undo last commit (soft reset)          |
| `gca`       | Amend last commit with current changes |
| `gcam`      | Amend last commit and edit message     |
| `grb`       | `git rebase`                           |
| `grbm`      | Rebase current branch on main          |
| `grbc`      | Rebase continue (auto-add files)       |
| `grba`      | Rebase abort                           |
| `grv <sha>` | Revert specific commit                 |
| `grvl`      | Revert last commit                     |
| `grvc`      | Revert continue                        |
| `gsq 3`     | Squash last 3 commits                  |
| `gst`       | `git stash`                            |
| `gstp`      | `git stash pop`                        |
| `gstl`      | `git stash list`                       |
| `gstd`      | `git stash drop`                       |
| `gtc`       | Clean local tags not on remote         |

### Infrastructure as Code

| Command | Description                          |
| ------- | ------------------------------------ |
| `ti`    | `terraform init`                     |
| `ta`    | `terraform apply`                    |
| `taa`   | `terraform apply -auto-approve`      |
| `td`    | `terraform destroy`                  |
| `tda`   | `terraform destroy -auto-approve`    |
| `tf`    | `terraform fmt`                      |
| `tv`    | `terraform validate`                 |
| `tc`    | Terraform clean (remove state files) |

### Utilities

| Command             | Description                       |
| ------------------- | --------------------------------- |
| `ll`                | List files with details           |
| `la`                | List all files (including hidden) |
| `which cmd`         | Find command location             |
| `grep`              | Search in files                   |
| `touch file`        | Create empty file                 |
| `mkcd dir`          | Create and enter directory        |
| `find-file name`    | Search for files by name          |
| `find-text pattern` | Search for text in files          |
| `calc "2+2"`        | Quick calculator                  |
| `sysinfo`           | Show system information           |
| `reload`            | Reload PowerShell profile         |
| `help-me`           | Show all available commands       |

## Platform-Specific Notes

### Windows

- Requires [AutoHotkey v2](https://www.autohotkey.com/) for keyboard shortcuts
- PowerShell profile location: `$PROFILE` (typically `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`)
- The install script will:
  - Copy PowerShell profile to `$PROFILE`
  - Copy AutoHotkey script to startup folder (auto-runs on login)
  - Set AutoHotkey to run at startup

### macOS

- Requires [Karabiner-Elements](https://karabiner-elements.pqrs.org/) for keyboard shortcuts
- PowerShell profile location: `~/.config/powershell/Microsoft.PowerShell_profile.ps1`
- Bash profile location: `~/.bash_profile`
- The install script will:
  - Symlink PowerShell profile
  - Symlink bash profile
  - Copy Karabiner config to `~/.config/karabiner/karabiner.json`

### Linux

- PowerShell profile location: `~/.config/powershell/Microsoft.PowerShell_profile.ps1`
- Bash profile location: `~/.bash_profile` or `~/.bashrc`
- No keyboard shortcut manager included (use your DE's shortcuts)

## Customization

### Work-Specific Settings

The PowerShell profile automatically loads work-specific settings if you're on a work machine (detected via `$env:USERDOMAIN`).

Create a file at `PowerShell/work-specific.ps1` with your work customizations:

```powershell
# Example work-specific settings
function work-server {
    ssh user@work-server.com
}

# Override repositories path
function r { Set-Location "D:\WorkRepos" }
```

### Additional Functions

Create `PowerShell/functions.ps1` for additional custom functions:

```powershell
function my-custom-function {
    # Your code here
}
```

### Environment Variables

For bash, create `~/.env` for secret environment variables:

```bash
export GEMINI_API_KEY="your-api-key-here"
export AZDO_PERSONAL_ACCESS_TOKEN="your-token-here"
```

## Troubleshooting

### PowerShell: "Cannot be loaded because running scripts is disabled"

Run PowerShell as Administrator and execute:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### AutoHotkey: Shortcuts not working

1. Make sure AutoHotkey v2 is installed
2. Check if script is running (system tray icon)
3. Run script as administrator if needed

### Karabiner: Shortcuts not working

1. Grant necessary permissions in System Settings > Privacy & Security
2. Restart Karabiner-Elements
3. Check that your config is loaded in Karabiner UI

### Git Commands: LLM features not working

Some commands (like auto-generating commit messages) require:

- `GEMINI_API_KEY` environment variable set
- `jq` installed (Windows: `winget install jqlang.jq`)

### Mac: Bash not loading profile

Add to `~/.bashrc`:

```bash
if [ -f ~/.bash_profile ]; then
    source ~/.bash_profile
fi
```

## Dependencies

### Required

- **Git** - All platforms
- **PowerShell 5+** - Windows (built-in), Mac/Linux (install separately)

### Optional but Recommended

- **AutoHotkey v2** - Windows keyboard shortcuts
- **Karabiner-Elements** - Mac keyboard shortcuts
- **GitHub CLI** (`gh`) - For `gpr` command on GitHub repos
- **jq** - For Azure DevOps pull requests and LLM features
- **curl** - For remote bash profile sourcing

## Credits

- Bash profile inherits from [Zamiell's configs](https://github.com/Zamiell/configs)

**Pro tip:** Type `help-me` in PowerShell to see all available commands!
