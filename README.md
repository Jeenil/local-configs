# local-configs

```powershell
# Clone repository
git clone https://github.com/Jeenil/local-configs.git "$env:USERPROFILE\repos\local-configs"

# Run setup script
& "$env:USERPROFILE\repos\local-configs\Setup-PowerShellProfile.ps1"
```

## PowerShell Features

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

## Customization

### AutoHotkey
- Edit `AutoHotkey/main.ahk` to add or modify shortcuts
- Reload with `Ctrl+Shift+Alt+R` after changes
After making changes:

On another machine:

```powershell
Update-Profile  # This pulls changes and reloads
```

Based on detection:
- Repository location adjusts (`C:\repos` vs `C:\repositories`)
- Navigation shortcuts adapt (work folder vs projects folder)
- Prompt colors indicate environment

## Included Tools

- [x] PowerShell profiles (PS5 & PS7)
- [x] AutoHotkey productivity shortcuts
- [x] Universal setup script
- [ ] Windows Terminal settings
- [ ] VS Code settings sync
- [ ] Git configuration

This is a personal configuration repository, but feel free to fork and adapt for your own use!
