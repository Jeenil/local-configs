# Run this after cloning local-configs on a new machine.
# Copies config files to their live locations.

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path

# VSCodium
Copy-Item "$repo\VSCodium\settings.json" "$env:APPDATA\Codium\User\settings.json" -Force
Write-Host "VSCodium settings applied"

# PowerShell profile
Copy-Item "$repo\PowerShell\PowerShell_profile.ps1" $PROFILE -Force
Write-Host "PowerShell profile applied"
