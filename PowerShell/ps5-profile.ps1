# PowerShell 5 Specific Profile
# Only PS5-specific settings go here

# PS5 doesn't have some of the newer features, so we add fallbacks if needed
if (-not (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue)) {
    Write-Host "PSReadLine not available in this PS5 installation" -ForegroundColor Yellow
}

# PS5 specific - Ensure TLS 1.2 for web requests
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# PS5 specific - Legacy Windows PowerShell modules path
if ($env:PSModulePath -notlike "*WindowsPowerShell\Modules*") {
    $env:PSModulePath += ";$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
}