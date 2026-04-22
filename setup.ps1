# Run this after cloning local-configs on a new machine.
# Copies all config files to their live locations.

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path

# VSCodium
Copy-Item "$repo\VSCodium\settings.json" "$env:APPDATA\Codium\User\settings.json" -Force
Write-Host "VSCodium settings applied"

# PowerShell profile
Copy-Item "$repo\PowerShell\PowerShell_profile.ps1" $PROFILE -Force
Write-Host "PowerShell profile applied"

# AutoHotkey — copy to Windows startup folder so it runs on login
$startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
Copy-Item "$repo\AutoHotkey\main.ahk" "$startup\main.ahk" -Force
Write-Host "AutoHotkey script added to startup"

# Git Bash profile
$gitBashHome = "$env:USERPROFILE"
Copy-Item "$repo\bash\.bash_profile" "$gitBashHome\.bash_profile" -Force
Write-Host "Git Bash profile applied"

Write-Host "`nDone. Restart AutoHotkey and reload your PowerShell and Git Bash sessions."
