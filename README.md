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
├── AutoHotkey/                 # (Future) AutoHotkey scripts
└── README.md
```

## 🚀 Quick Setup

### PowerShell Profile Setup

1. Clone this repository:
   ```powershell
   git clone https://github.com/Jeenil/local-configs.git "$env:USERPROFILE\repos\local-configs"
   ```

2. Create a loader profile that points to this repo:
   ```powershell
   # Create the loader profile
   @"
   # PowerShell Profile Loader
   `$repoPath = "$env:USERPROFILE\repos\local-configs"
   if (Test-Path `$repoPath) {
       . "`$repoPath\PowerShell\common-profile.ps1"
       `$versionProfile = if (`$PSVersionTable.PSVersion.Major -ge 7) {
           "`$repoPath\PowerShell\ps7-profile.ps1"
       } else {
           "`$repoPath\PowerShell\ps5-profile.ps1"
       }
       if (Test-Path `$versionProfile) { . `$versionProfile }
   }
   "@ | Set-Content -Path $PROFILE -Force
   
   # Reload profile
   . $PROFILE
   ```

## 📋 PowerShell Features

### Aliases
- `ll` - List files (alias for Get-ChildItem)
- `la` - List all files including hidden
- `which` - Find command location
- `grep` - Search in files (Select-String)
- `touch` - Create new file
- `e` - Open Explorer in current directory

### Git Shortcuts
- `gs` - git status
- `ga` - git add
- `gc` - git commit -m
- `gp` - git push
- `gpull` - git pull
- `gl` - git log (last 10 commits)
- `gco` - git checkout

### Navigation
- `repos` - Go to ~/repos
- `home` - Go to home directory
- `desktop` - Go to Desktop
- `downloads` - Go to Downloads
- `up [n]` - Go up n directories
- `mkcd <name>` - Create and enter directory

### Utilities
- `Get-MyIP` - Show local and public IP addresses
- Custom colored prompt with git branch display

## 🔧 Customization

### Adding New Aliases or Functions

Edit `PowerShell/common-profile.ps1` to add aliases or functions that should be available in all PowerShell sessions.

### Version-Specific Settings

- **PowerShell 5.x**: Edit `PowerShell/ps5-profile.ps1`
- **PowerShell 7+**: Edit `PowerShell/ps7-profile.ps1`

### Adding Scripts

Drop any `.ps1` files into `PowerShell/Scripts/` and they'll be automatically loaded.

## 🔄 Syncing Changes

After making changes:

```powershell
cd "$env:USERPROFILE\repos\local-configs"
git add .
git commit -m "Update PowerShell configuration"
git push
```

On another machine:

```powershell
cd "$env:USERPROFILE\repos\local-configs"
git pull
. $PROFILE  # Reload profile
```

## 🖥️ Multi-Machine Setup

This configuration supports multiple machines. The profile loader always points to the local clone of this repository, making it easy to:

1. Make changes on one machine
2. Push to GitHub
3. Pull on another machine
4. Changes are immediately available

## 📝 Future Additions

- [ ] AutoHotkey scripts for productivity
- [ ] Windows Terminal settings
- [ ] VS Code settings sync
- [ ] Git configuration
- [ ] Additional PowerShell modules

## 🤝 Contributing

This is a personal configuration repository, but feel free to fork and adapt for your own use!

## 📄 License

MIT - Feel free to use and modify as needed.