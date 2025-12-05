# PowerShell Profile - Mirrors bash configuration from GitHub
# This profile loads commands from a remote GitHub repository

# Load the commands from the "local-configs" GitHub repository
$configDir = "$HOME\.config"
$remoteProfilePath = "$configDir\.powershell_profile_remote.ps1"

# Create config directory if it doesn't exist
if (!(Test-Path -Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# Download the remote profile
Remove-Item -Path $remoteProfilePath -Force -ErrorAction SilentlyContinue
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Jeenil/local-configs/main/PowerShell/profile_remote.ps1" `
        -OutFile $remoteProfilePath `
        -UseBasicParsing `
        -ErrorAction Stop
    
    # Source the remote profile
    . $remoteProfilePath
} catch {
    Write-Warning "Failed to download remote PowerShell profile: $_"
    Write-Warning "Falling back to local configuration..."
}