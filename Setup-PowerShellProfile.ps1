# install.ps1 - Simple Profile Installer
Write-Host "Installing PowerShell Profile..." -ForegroundColor Cyan

# Setup paths
$localDir = "C:\_it\PowerShell"
$repoUrl = "https://github.com/Jeenil/local-configs.git"

# Create directory
New-Item -Path $localDir -ItemType Directory -Force | Out-Null

# Clone or update repo
if (!(Test-Path "$localDir\.git")) {
    git clone $repoUrl $localDir
} else {
    Push-Location $localDir
    git pull
    Pop-Location
}

# Create loader in PowerShell profile
$loader = @"
# Load profile from local directory
. "C:\_it\PowerShell\PowerShell\profile.ps1"
"@

# Backup and install
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
}

$loader | Set-Content -Path $PROFILE -Encoding UTF8
Write-Host "Done! Restart PowerShell." -ForegroundColor Green