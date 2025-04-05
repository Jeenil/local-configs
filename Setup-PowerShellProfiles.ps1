# Setup-PowerShellProfiles.ps1
# Script to set up synchronized PowerShell profiles for PS5 and PS7
# Ensures both PowerShell versions use the same repository location

# Define the profile paths
$ps5ProfilePath = "$env:USERPROFILE\OneDrive - LogixHealth Inc\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$ps7ProfilePath = "$env:USERPROFILE\OneDrive - LogixHealth Inc\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# Define the absolute path to your repository
# We'll get this from the current script's location
$scriptPath = $MyInvocation.MyCommand.Path
$repoLocalPath = Split-Path -Parent $scriptPath
$repoLocalPath = Resolve-Path $repoLocalPath

Write-Host "Repository path detected as: $repoLocalPath" -ForegroundColor Cyan
Write-Host "This path will be hardcoded in both profile files" -ForegroundColor Cyan

# Ensure the profile directories exist
$ps5ProfileDir = Split-Path -Parent $ps5ProfilePath
$ps7ProfileDir = Split-Path -Parent $ps7ProfilePath

if (-not (Test-Path $ps5ProfileDir)) {
    New-Item -Path $ps5ProfileDir -ItemType Directory -Force
    Write-Host "Created PS5 profile directory: $ps5ProfileDir" -ForegroundColor Green
}

if (-not (Test-Path $ps7ProfileDir)) {
    New-Item -Path $ps7ProfileDir -ItemType Directory -Force
    Write-Host "Created PS7 profile directory: $ps7ProfileDir" -ForegroundColor Green
}

# Create identical loader scripts for both PS5 and PS7 with the ABSOLUTE repository path
$loaderScript = @"
# PowerShell Profile Loader 
# Sources configuration from local repository: $repoLocalPath
# Auto-generated on $(Get-Date)

# The absolute repository path is hardcoded to ensure consistency
`$repoPath = "$repoLocalPath"

# Determine PowerShell version
`$isPowerShell7 = `$PSVersionTable.PSVersion.Major -ge 7
`$psVersion = `$PSVersionTable.PSVersion.Major

Write-Host "Loading profile from: `$repoPath" -ForegroundColor DarkGray
Write-Host "PowerShell Version: `$psVersion" -ForegroundColor DarkGray

# Source the common profile script from the repository
`$commonProfilePath = Join-Path `$repoPath "PowerShell\common-profile.ps1"
if (Test-Path `$commonProfilePath) {
    . `$commonProfilePath
} else {
    Write-Warning "Common profile script not found at: `$commonProfilePath"
}

# Source version-specific profile if it exists
if (`$isPowerShell7) {
    `$versionSpecificPath = Join-Path `$repoPath "PowerShell\ps7-profile.ps1"
} else {
    `$versionSpecificPath = Join-Path `$repoPath "PowerShell\ps5-profile.ps1"
}

if (Test-Path `$versionSpecificPath) {
    . `$versionSpecificPath
} else {
    Write-Warning "Version-specific profile not found at: `$versionSpecificPath"
}

# Source additional scripts from the Scripts directory
`$scriptsDir = Join-Path `$repoPath "PowerShell\Scripts"
if (Test-Path `$scriptsDir) {
    `$scripts = Get-ChildItem -Path `$scriptsDir -Filter "*.ps1" -File
    foreach (`$script in `$scripts) {
        try {
            . `$script.FullName
            Write-Host "Loaded script: `$(`$script.Name)" -ForegroundColor DarkGray
        } catch {
            Write-Warning "Error loading script `$(`$script.Name): `$_"
        }
    }
}

# Auto-sync the profile with GitHub on startup (optional - comment out if you don't want this)
if (Get-Command git -ErrorAction SilentlyContinue) {
    try {
        Push-Location `$repoPath
        git pull -q
        Pop-Location
    } catch {
        Write-Warning "Error syncing with git: `$_"
    }
}
"@

# Write the identical loader script to both profile files
Set-Content -Path $ps5ProfilePath -Value $loaderScript -Force
Set-Content -Path $ps7ProfilePath -Value $loaderScript -Force

Write-Host "`nProfile setup complete!" -ForegroundColor Green
Write-Host "PS5 Profile: $ps5ProfilePath" -ForegroundColor Cyan
Write-Host "PS7 Profile: $ps7ProfilePath" -ForegroundColor Cyan
Write-Host "Both profiles now point to the same repository path: $repoLocalPath" -ForegroundColor Green

# Check if the repository has the expected directory structure and create it if not
$powershellDir = Join-Path $repoLocalPath "PowerShell"
$commonProfilePath = Join-Path $powershellDir "common-profile.ps1"
$ps5ProfilePath = Join-Path $powershellDir "ps5-profile.ps1"
$ps7ProfilePath = Join-Path $powershellDir "ps7-profile.ps1"
$scriptsDir = Join-Path $powershellDir "Scripts"

Write-Host "`nChecking repository structure..." -ForegroundColor Yellow

# Create PowerShell directory if it doesn't exist
if (-not (Test-Path $powershellDir)) {
    Write-Host "Creating PowerShell directory in repository..." -ForegroundColor Yellow
    New-Item -Path $powershellDir -ItemType Directory -Force
}

# Create Scripts directory if it doesn't exist
if (-not (Test-Path $scriptsDir)) {
    Write-Host "Creating Scripts directory in repository..." -ForegroundColor Yellow
    New-Item -Path $scriptsDir -ItemType Directory -Force
}

# Create template files if they don't exist
$filesToCheck = @(
    @{Path = $commonProfilePath; Name = "Common Profile"; Template = @"
# Common PowerShell Profile - Works in both PS5 and PS7
# GitHub: Jeenil/local-configs

# Common aliases
Set-Alias -Name g -Value git
Set-Alias -Name c -Value cls

# Import common modules
Import-Module -Name PSReadLine -ErrorAction SilentlyContinue

# Common Git functions
function Get-GitStatus { git status }
Set-Alias -Name gs -Value Get-GitStatus
function Get-GitLog { git log --oneline -n 10 }
Set-Alias -Name gl -Value Get-GitLog
function New-GitBranch { param([Parameter(Mandatory)][string]$Name) git checkout -b $Name }
Set-Alias -Name gnb -Value New-GitBranch
function Switch-GitBranch { param([Parameter(Mandatory)][string]$Name) git checkout $Name }
Set-Alias -Name gsw -Value Switch-GitBranch
function Push-GitChanges { git push }
Set-Alias -Name gp -Value Push-GitChanges
function Add-GitChanges { git add . }
Set-Alias -Name ga -Value Add-GitChanges
function Commit-GitChanges { param([Parameter(Mandatory)][string]$Message) git commit -m $Message }
Set-Alias -Name gcm -Value Commit-GitChanges

function Update-Profile {
    # Define the repository path explicitly to ensure consistency
    `$repoPath = "$repoLocalPath"
    
    Push-Location `$repoPath
    git pull
    . `$PROFILE
    Pop-Location
    Write-Host "Profile updated and reloaded!" -ForegroundColor Green
}

# Custom prompt
function prompt {
    `$version = `$PSVersionTable.PSVersion.Major
    `$location = `$(Get-Location).Path
    Write-Host "PS[`$version] " -NoNewline -ForegroundColor Green
    Write-Host "`$location" -NoNewline -ForegroundColor Blue
    return " > "
}
"@},
    @{Path = $ps5ProfilePath; Name = "PS5 Profile"; Template = @"
# PowerShell 5 Specific Profile
# GitHub: Jeenil/local-configs

# PS5-specific modules
# Import-Module SomePS5Module

# PS5-specific aliases and functions
function Get-PS5Only {
    Write-Host "This function only works in PowerShell 5" -ForegroundColor Magenta
}
"@},
    @{Path = $ps7ProfilePath; Name = "PS7 Profile"; Template = @"
# PowerShell 7 Specific Profile
# GitHub: Jeenil/local-configs

# PS7-specific modules
# Import-Module SomePS7Module

# PS7-specific aliases and functions
function Get-PS7Only {
    Write-Host "This function only works in PowerShell 7" -ForegroundColor Cyan
}

# PS7 specific features
`$PSStyle.FileInfo.Directory = "`e[34;1m"
"@},
    @{Path = (Join-Path $scriptsDir "Example-Script.ps1"); Name = "Example Script"; Template = @"
# Example-Script.ps1
# This script will be automatically loaded by both PS5 and PS7 profiles

function Get-HelloWorld {
    param(
        [string]$Name = "World"
    )
    
    Write-Host "Hello, $Name!" -ForegroundColor Cyan
}
"@}
)

foreach ($file in $filesToCheck) {
    if (-not (Test-Path $file.Path)) {
        Write-Host "Creating $($file.Name) template: $($file.Path)" -ForegroundColor Yellow
        Set-Content -Path $file.Path -Value $file.Template -Force
    } else {
        Write-Host "$($file.Name) already exists: $($file.Path)" -ForegroundColor Green
    }
}

# Create a verification script to check that profiles are correctly set up
$verifyScriptPath = Join-Path $repoLocalPath "Verify-ProfileSetup.ps1"
$verifyScriptContent = @"
# Verify-ProfileSetup.ps1
# Verifies that both PS5 and PS7 profiles point to the same repository location

Write-Host "Profile Verification Tool" -ForegroundColor Cyan
Write-Host "------------------------" -ForegroundColor Cyan

# Current PowerShell version
`$currentVersion = `$PSVersionTable.PSVersion.Major
Write-Host "Current PowerShell version: `$currentVersion" -ForegroundColor Yellow

# Current profile path
Write-Host "Current profile path: `$PROFILE" -ForegroundColor Yellow

# Check if profile exists
if (Test-Path `$PROFILE) {
    Write-Host "Profile exists: Yes" -ForegroundColor Green
    
    # Get the content of the profile
    `$profileContent = Get-Content `$PROFILE -Raw
    
    # Check if the repository path is in the profile
    if (`$profileContent -like "*$repoLocalPath*") {
        Write-Host "Repository path found in profile: Yes" -ForegroundColor Green
        Write-Host "Repository path: $repoLocalPath" -ForegroundColor Green
    } else {
        Write-Host "Repository path found in profile: No" -ForegroundColor Red
        Write-Host "Please run Setup-PowerShellProfiles.ps1 to fix this" -ForegroundColor Red
    }
} else {
    Write-Host "Profile exists: No" -ForegroundColor Red
    Write-Host "Please run Setup-PowerShellProfiles.ps1 to create the profile" -ForegroundColor Red
}

# Check if repository files exist
`$powershellDir = Join-Path "$repoLocalPath" "PowerShell"
`$commonProfilePath = Join-Path `$powershellDir "common-profile.ps1"
`$versionSpecificPath = Join-Path `$powershellDir "ps`$currentVersion-profile.ps1"

if (Test-Path `$commonProfilePath) {
    Write-Host "Common profile exists: Yes" -ForegroundColor Green
} else {
    Write-Host "Common profile exists: No" -ForegroundColor Red
}

if (Test-Path `$versionSpecificPath) {
    Write-Host "PS`$currentVersion profile exists: Yes" -ForegroundColor Green
} else {
    Write-Host "PS`$currentVersion profile exists: No" -ForegroundColor Red
}

Write-Host "`nIf any issues were found, please run Setup-PowerShellProfiles.ps1 to fix them" -ForegroundColor Yellow
"@

Set-Content -Path $verifyScriptPath -Value $verifyScriptContent -Force
Write-Host "Created verification script: $verifyScriptPath" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Review and customize the template files in: $powershellDir" -ForegroundColor White
Write-Host "2. Add any additional PowerShell scripts to: $scriptsDir" -ForegroundColor White
Write-Host "3. Commit and push your changes to GitHub:" -ForegroundColor White
Write-Host "   git add ." -ForegroundColor Gray
Write-Host "   git commit -m 'Added PowerShell profiles and scripts'" -ForegroundColor Gray
Write-Host "   git push" -ForegroundColor Gray
Write-Host "4. Restart PowerShell to apply the changes" -ForegroundColor White
Write-Host "5. Run Verify-ProfileSetup.ps1 to confirm everything is working" -ForegroundColor White
Write-Host "6. To update your profile in the future, run: Update-Profile" -ForegroundColor White