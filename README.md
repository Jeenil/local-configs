# local-configs

Personal configuration files for PowerShell, AutoHotkey, and other local development tools.

## 📁 Repository Structure

```
local-configs/
├── PowerShell/
│   ├── common-profile.ps1      # Common profile loaded in all PS sessions
│   ├── ps5-profile.ps1         # PowerShell 5.x specific settings
│   ├── ps7-profile.ps1         # PowerShell 7+ specific settings
│   └── Scripts/                # Additional PowerShell scripts
├── AutoHotkey/
│   └── main.ahk               # AutoHotkey shortcuts and productivity scripts
├── Setup-PowerShellProfile.ps1 # Universal setup script
└── README.md
```

## 🚀 Quick Setup

### One-Line Setup (Recommended)

Run this command in PowerShell on any machine (work or personal):

```powershell
irm https://raw.githubusercontent.com/Jeenil/local-configs/main/Setup-PowerShellProfile.ps1 | iex
```

This automatically:
- Detects if you're on a work or personal machine
- Clones the repository to the correct location
- Sets up your PowerShell profile
- Creates all necessary directories

### Manual Setup

If you prefer to set up manually:

```powershell
# Clone repository
git clone https://github.com/Jeenil/local-configs.git "$env:USERPROFILE\repos\local-configs"

# Run setup script
& "$env:USERPROFILE\repos\local-configs\Setup-PowerShellProfile.ps1"
```

## 📋 PowerShell Features

### Aliases
- `ll` - List files (detailed view)
- `la` - List all files including hidden
- `which` - Find command location
- `grep` - Search in files (Select-String)
- `touch` - Create new file
- `e` - Open Explorer in current directory
- `c` - Clear screen

### Navigation Shortcuts
- `r` / `repos` - Go to repositories folder
- `h` / `docs` - Go to Documents folder
- `home` - Go to user home
- `desktop` - Go to Desktop
- `downloads` - Go to Downloads
- `up [n]` - Go up n directories
- `mkcd <name>` - Create and enter directory
- `projects` - Go to projects folder (personal machines only)
- `work` - Go to work folder (work machines only)

### Utilities
- `Get-MyIP` - Show local and public IP addresses
- `Update-Profile` - Pull latest changes and reload profile
- `help-me` - Show all available commands
- Custom colored prompt with environment indicator

## ⌨️ AutoHotkey Shortcuts

### Core Hotkeys
- `Ctrl+Shift+Alt+R` - Reload AutoHotkey script
- `Ctrl+Shift+Alt+S` - Suspend/resume AutoHotkey
- `Win+Down` - Minimize active window

### Window Cycling
- `Win+Tab` - Cycle forward through windows of the same program
- `Win+Shift+Tab` - Cycle backward through windows of the same program

### Quick Launch Applications
- `Ctrl+1` - Windows Terminal
- `Ctrl+2` - VS Code
- `Ctrl+3` - Obsidian
- `Ctrl+4` - Chrome
- `Ctrl+5` - Edge
- `Ctrl+6` - Notepad++

### AutoHotkey Setup

1. Install AutoHotkey v2: https://www.autohotkey.com/
2. The setup script will link to the AutoHotkey config in this repo
3. Or manually run: `AutoHotkey\main.ahk`

To auto-start with Windows:
```powershell
# Create startup shortcut
$startup = [Environment]::GetFolderPath('Startup')
$target = "$env:USERPROFILE\repos\local-configs\AutoHotkey\main.ahk"
$shortcut = "$startup\AutoHotkey.lnk"

$shell = New-Object -ComObject WScript.Shell
$link = $shell.CreateShortcut($shortcut)
$link.TargetPath = $target
$link.Save()
```

## 🔧 Customization

### PowerShell
- **Common settings**: Edit `PowerShell/common-profile.ps1`
- **PS5-specific**: Edit `PowerShell/ps5-profile.ps1`
- **PS7-specific**: Edit `PowerShell/ps7-profile.ps1`
- **Add scripts**: Drop `.ps1` files in `PowerShell/Scripts/`

### AutoHotkey
- Edit `AutoHotkey/main.ahk` to add or modify shortcuts
- Reload with `Ctrl+Shift+Alt+R` after changes

## 🔄 Syncing Changes

After making changes:

```powershell
cd "$env:USERPROFILE\repos\local-configs"  # or C:\repositories\local-configs
git add .
git commit -m "Update configuration"
git push
```

On another machine:

```powershell
Update-Profile  # This pulls changes and reloads
```

## 🖥️ Multi-Machine Support

The configuration automatically detects:
- **Work machines**: Domain matches LogixHealth or username is jeepatel
- **Personal machines**: Everything else

Based on detection:
- Repository location adjusts (`C:\repos` vs `C:\repositories`)
- Navigation shortcuts adapt (work folder vs projects folder)
- Prompt colors indicate environment

## 📝 Included Tools

- [x] PowerShell profiles (PS5 & PS7)
- [x] AutoHotkey productivity shortcuts
- [x] Universal setup script
- [ ] Windows Terminal settings
- [ ] VS Code settings sync
- [ ] Git configuration

## 🤝 Contributing

This is a personal configuration repository, but feel free to fork and adapt for your own use!
