# Setup-PowerShellProfile.ps1
# Universal setup script for both work and personal machines
# Can be run directly from GitHub or locally

param(
    [switch]$Force = $false,
    [switch]$SkipGitClone = $false
)

Write-Host @"
╔═══════════════════════════════════════════╗
║   PowerShell Profile Setup Script         ║
║   Works on both Work & Personal Machines  ║
╚═══════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Detect environment
$isWorkMachine = $env:USERDOMAIN -match "LogixHealth|LOGIX" -or $env:USERNAME -eq "jeepatel"
$envType = if ($isWorkMachine) { "Work" } else { "Personal" }
$repoBasePath = if ($isWorkMachine) { "C:\repos" } else { "C:\repositories" }
$localRepoPath = Join-Path $repoBasePath "local-configs"

Write-Host "Detected Environment: $envType" -ForegroundColor Green
Write-Host "Repository Path: $localRepoPath" -ForegroundColor Yellow
Write-Host ""

# Step 1: Ensure base directory exists
if (!(Test-Path $repoBasePath)) {
    Write-Host "Creating base directory: $repoBasePath" -ForegroundColor Yellow
    New-Item -Path $repoBasePath -ItemType Directory -Force | Out-Null
}

# Step 2: Clone or update repository
if (!$SkipGitClone) {
    if (!(Test-Path $localRepoPath)) {
        Write-Host "Cloning repository from GitHub..." -ForegroundColor Yellow
        try {
            git clone "https://github.com/Jeenil/local-configs.git" $localRepoPath
            Write-Host "Repository cloned successfully!" -ForegroundColor Green
        } catch {
            Write-Host "Failed to clone repository. Make sure:" -ForegroundColor Red
            Write-Host "  1. Git is installed (https://git-scm.com/download/win)" -ForegroundColor Yellow
            Write-Host "  2. You have internet connection" -ForegroundColor Yellow
            Write-Host "  3. You have access to the repository" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "Repository already exists. Pulling latest changes..." -ForegroundColor Yellow
        Push-Location $localRepoPath
        git pull
        Pop-Location
    }
}

# Step 3: Create PowerShell profile directory if needed
$profileDir = Split-Path $PROFILE -Parent
if (!(Test-Path $profileDir)) {
    Write-Host "Creating PowerShell profile directory..." -ForegroundColor Yellow
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}

# Step 4: Backup existing profile
if (Test-Path $PROFILE) {
    $backupPath = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $PROFILE $backupPath
    Write-Host "Backed up existing profile to:" -ForegroundColor Green
    Write-Host "  $backupPath" -ForegroundColor Gray
}

# Step 5: Create the loader profile
$loaderContent = @"
# PowerShell Profile Loader
# This loads configuration from local-configs repository
# Environment: $envType
# Generated: $(Get-Date)

`$repoPath = "$localRepoPath"

# Verify repository exists
if (!(Test-Path "`$repoPath")) {
    Write-Warning "Repository not found at: `$repoPath"
    Write-Host "Run this to clone it:" -ForegroundColor Yellow
    Write-Host "  git clone https://github.com/Jeenil/local-configs.git '`$repoPath'" -ForegroundColor Cyan
    return
}

# Load common profile
`$commonProfile = Join-Path "`$repoPath" "PowerShell\common-profile.ps1"
if (Test-Path "`$commonProfile") {
    . "`$commonProfile"
} else {
    Write-Warning "Common profile not found at: `$commonProfile"
}

# Load version-specific profile
`$versionProfile = if (`$PSVersionTable.PSVersion.Major -ge 7) {
    Join-Path "`$repoPath" "PowerShell\ps7-profile.ps1"
} else {
    Join-Path "`$repoPath" "PowerShell\ps5-profile.ps1"
}

if (Test-Path "`$versionProfile") {
    . "`$versionProfile"
}

# Load any additional scripts
`$scriptsDir = Join-Path "`$repoPath" "PowerShell\Scripts"
if (Test-Path "`$scriptsDir") {
    Get-ChildItem "`$scriptsDir" -Filter "*.ps1" | ForEach-Object {
        . `$_.FullName
    }
}
"@

# Step 6: Install the loader profile
if ($Force -or !(Test-Path $PROFILE) -or (Read-Host "Install/Update profile? (y/n)") -eq 'y') {
    $loaderContent | Set-Content -Path $PROFILE -Encoding UTF8
    Write-Host "`n✓ Profile installed successfully!" -ForegroundColor Green
} else {
    Write-Host "`nProfile installation skipped." -ForegroundColor Yellow
}

# Step 7: Display next steps
Write-Host "`n" + ("="*50) -ForegroundColor DarkGray
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host ("="*50) -ForegroundColor DarkGray

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Reload your profile:" -ForegroundColor Gray
Write-Host "   . `$PROFILE" -ForegroundColor Cyan

if (!$SkipGitClone) {
    Write-Host "`n2. Update the repository with your changes:" -ForegroundColor Gray
    Write-Host "   cd '$localRepoPath'" -ForegroundColor Cyan
    Write-Host "   git add ." -ForegroundColor Cyan
    Write-Host "   git commit -m 'Update PowerShell profiles'" -ForegroundColor Cyan
    Write-Host "   git push" -ForegroundColor Cyan
}

Write-Host "`n3. To set up on another machine, run:" -ForegroundColor Gray
Write-Host "   irm https://raw.githubusercontent.com/Jeenil/local-configs/main/Setup-PowerShellProfile.ps1 | iex" -ForegroundColor Cyan

Write-Host "`n4. View available commands:" -ForegroundColor Gray
Write-Host "   help-me" -ForegroundColor Cyan

Write-Host "`nProfile Location: $PROFILE" -ForegroundColor DarkGray
Write-Host "Repository: $localRepoPath" -ForegroundColor DarkGray