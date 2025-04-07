# Fix-PowerShellProfiles.ps1
# This script directly creates profile files with hardcoded paths
# Run with administrator privileges if possible

# Define the profile paths explicitly
$ps5ProfilePath = "$env:USERPROFILE\OneDrive - LogixHealth Inc\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$ps7ProfilePath = "$env:USERPROFILE\OneDrive - LogixHealth Inc\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# Hardcode the repository path
$repoLocalPath = "C:\repositories\local-configs"

Write-Host "Using hardcoded repository path: $repoLocalPath" -ForegroundColor Cyan
Write-Host "PS5 Profile Path: $ps5ProfilePath" -ForegroundColor Cyan
Write-Host "PS7 Profile Path: $ps7ProfilePath" -ForegroundColor Cyan

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

# Create identical loader scripts for both PS5 and PS7 with the hardcoded repository path
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
"@

# Try to write the profile files with detailed error reporting
try {
    # Write PS5 profile
    Write-Host "Attempting to write PS5 profile..." -ForegroundColor Yellow
    Set-Content -Path $ps5ProfilePath -Value $loaderScript -Force -ErrorAction Stop
    Write-Host "PS5 profile successfully written!" -ForegroundColor Green
} catch {
    Write-Host "Error writing PS5 profile: $_" -ForegroundColor Red
    Write-Host "Attempting alternative method for PS5..." -ForegroundColor Yellow
    
    try {
        # Alternative method using Out-File
        $loaderScript | Out-File -FilePath $ps5ProfilePath -Force -Encoding utf8
        if (Test-Path $ps5ProfilePath) {
            Write-Host "PS5 profile written using alternative method!" -ForegroundColor Green
        } else {
            Write-Host "Failed to write PS5 profile using alternative method." -ForegroundColor Red
        }
    } catch {
        Write-Host "Alternative method also failed: $_" -ForegroundColor Red
    }
}

try {
    # Write PS7 profile
    Write-Host "Attempting to write PS7 profile..." -ForegroundColor Yellow
    Set-Content -Path $ps7ProfilePath -Value $loaderScript -Force -ErrorAction Stop
    Write-Host "PS7 profile successfully written!" -ForegroundColor Green
} catch {
    Write-Host "Error writing PS7 profile: $_" -ForegroundColor Red
    Write-Host "Attempting alternative method for PS7..." -ForegroundColor Yellow
    
    try {
        # Alternative method using Out-File
        $loaderScript | Out-File -FilePath $ps7ProfilePath -Force -Encoding utf8
        if (Test-Path $ps7ProfilePath) {
            Write-Host "PS7 profile written using alternative method!" -ForegroundColor Green
        } else {
            Write-Host "Failed to write PS7 profile using alternative method." -ForegroundColor Red
        }
    } catch {
        Write-Host "Alternative method also failed: $_" -ForegroundColor Red
    }
}

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

# Create manual copy instructions if PowerShell can't write to the profile files
$manualInstructionsPath = Join-Path $repoLocalPath "Manual-Profile-Setup.txt"
$manualInstructions = @"
== MANUAL PROFILE SETUP INSTRUCTIONS ==

If the automatic setup script couldn't write to your profile files, follow these steps:

1. Copy the following text:
------------- BEGIN PROFILE TEXT -------------
$loaderScript
------------- END PROFILE TEXT -------------

2. Manually paste this text into both of these files:
   - PS5 Profile: $ps5ProfilePath
   - PS7 Profile: $ps7ProfilePath

3. Create the following directory structure in your repository if it doesn't exist:
   - $powershellDir
   - $scriptsDir

4. Restart PowerShell after making these changes

== END OF INSTRUCTIONS ==
"@

Set-Content -Path $manualInstructionsPath -Value $manualInstructions -Force
Write-Host "`nCreated manual setup instructions at: $manualInstructionsPath" -ForegroundColor Yellow
Write-Host "If the automatic setup didn't work, follow these manual instructions." -ForegroundColor Yellow

# Display verification steps
Write-Host "`nTo verify the setup:" -ForegroundColor Cyan
Write-Host "1. Restart both PowerShell 5 and PowerShell 7" -ForegroundColor White
Write-Host "2. Run the following command in each:" -ForegroundColor White
Write-Host "   Write-Host `"Repository path: $repoLocalPath`" -ForegroundColor Green; Write-Host `"Profile path: `$PROFILE`" -ForegroundColor Cyan" -ForegroundColor Gray
Write-Host "3. The repository path should appear correctly in both PS5 and PS7" -ForegroundColor White