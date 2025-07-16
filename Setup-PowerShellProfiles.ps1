# Manage-PowerShellProfiles.ps1
# This script checks the current PowerShell profile location and compares it with repository content
# It can sync profiles between the repository and the actual profile locations

param(
    [string]$RepositoryPath = "C:\repositories\local-configs",
    [switch]$DryRun = $false,
    [switch]$Force = $false,
    [switch]$Verbose = $false
)

Write-Host "PowerShell Profile Manager" -ForegroundColor Green
Write-Host "Repository: $RepositoryPath" -ForegroundColor Cyan
Write-Host "Current Profile: $PROFILE" -ForegroundColor Cyan
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
Write-Host ""

# Repository profile paths
$repoProfilesDir = Join-Path $RepositoryPath "PowerShell"
$repoCommonProfile = Join-Path $repoProfilesDir "common-profile.ps1"
$repoPS5Profile = Join-Path $repoProfilesDir "ps5-profile.ps1"
$repoPS7Profile = Join-Path $repoProfilesDir "ps7-profile.ps1"
$repoScriptsDir = Join-Path $repoProfilesDir "Scripts"

# Current PowerShell profile information
$currentProfile = $PROFILE
$currentProfileDir = Split-Path -Parent $currentProfile
$isPowerShell7 = $PSVersionTable.PSVersion.Major -ge 7
$psVersion = $PSVersionTable.PSVersion.Major

Write-Host "Analysis Results:" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Yellow

# Check if repository structure exists
function Test-RepositoryStructure {
    $issues = @()
    
    if (-not (Test-Path $RepositoryPath)) {
        $issues += "Repository path does not exist: $RepositoryPath"
    }
    
    if (-not (Test-Path $repoProfilesDir)) {
        $issues += "PowerShell profiles directory missing: $repoProfilesDir"
    }
    
    if (-not (Test-Path $repoCommonProfile)) {
        $issues += "Common profile missing: $repoCommonProfile"
    }
    
    if ($isPowerShell7 -and -not (Test-Path $repoPS7Profile)) {
        $issues += "PS7 profile missing: $repoPS7Profile"
    }
    
    if (-not $isPowerShell7 -and -not (Test-Path $repoPS5Profile)) {
        $issues += "PS5 profile missing: $repoPS5Profile"
    }
    
    return $issues
}

# Check current profile status
function Get-ProfileStatus {
    $status = @{
        Exists = Test-Path $currentProfile
        IsLoader = $false
        PointsToRepo = $false
        Content = $null
        RepoContent = $null
        InSync = $false
    }
    
    if ($status.Exists) {
        $status.Content = Get-Content $currentProfile -Raw -ErrorAction SilentlyContinue
        
        # Check if it's a loader script
        if ($status.Content -and $status.Content.Contains("PowerShell Profile Loader")) {
            $status.IsLoader = $true
            
            # Check if it points to the correct repository
            if ($status.Content.Contains($RepositoryPath)) {
                $status.PointsToRepo = $true
            }
        }
        
        # Get the expected loader content
        $status.RepoContent = Get-LoaderScript
        
        # Check if content matches
        if ($status.Content -and $status.RepoContent) {
            # Normalize line endings and whitespace for comparison
            $normalizedCurrent = $status.Content -replace '\r\n', "`n" -replace '\s+$', ''
            $normalizedRepo = $status.RepoContent -replace '\r\n', "`n" -replace '\s+$', ''
            $status.InSync = $normalizedCurrent -eq $normalizedRepo
        }
    }
    
    return $status
}

# Generate the loader script content
function Get-LoaderScript {
    return @"
# PowerShell Profile Loader 
# Sources configuration from local repository: $RepositoryPath
# Auto-generated on $(Get-Date)

# The absolute repository path is hardcoded to ensure consistency
`$repoPath = "$RepositoryPath"

# Determine PowerShell version
`$isPowerShell7 = `$PSVersionTable.PSVersion.Major -ge 7
`$psVersion = `$PSVersionTable.PSVersion.Major

if (`$env:POWERSHELL_PROFILE_VERBOSE -eq '1') {
    Write-Host "Loading profile from: `$repoPath" -ForegroundColor DarkGray
    Write-Host "PowerShell Version: `$psVersion" -ForegroundColor DarkGray
}

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
            if (`$env:POWERSHELL_PROFILE_VERBOSE -eq '1') {
                Write-Host "Loaded script: `$(`$script.Name)" -ForegroundColor DarkGray
            }
        } catch {
            Write-Warning "Error loading script `$(`$script.Name): `$_"
        }
    }
}
"@
}

# Main analysis
$repoIssues = Test-RepositoryStructure
$profileStatus = Get-ProfileStatus

# Display results
if ($repoIssues.Count -gt 0) {
    Write-Host "Repository Issues:" -ForegroundColor Red
    foreach ($issue in $repoIssues) {
        Write-Host "  × $issue" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "Profile Status:" -ForegroundColor Yellow
Write-Host "  Profile exists: $(if ($profileStatus.Exists) { 'Yes' } else { 'No' })" -ForegroundColor $(if ($profileStatus.Exists) { 'Green' } else { 'Red' })
Write-Host "  Is loader script: $(if ($profileStatus.IsLoader) { 'Yes' } else { 'No' })" -ForegroundColor $(if ($profileStatus.IsLoader) { 'Green' } else { 'Yellow' })
Write-Host "  Points to repo: $(if ($profileStatus.PointsToRepo) { 'Yes' } else { 'No' })" -ForegroundColor $(if ($profileStatus.PointsToRepo) { 'Green' } else { 'Red' })
Write-Host "  Content in sync: $(if ($profileStatus.InSync) { 'Yes' } else { 'No' })" -ForegroundColor $(if ($profileStatus.InSync) { 'Green' } else { 'Red' })

if ($Verbose -and $profileStatus.Content) {
    Write-Host ""
    Write-Host "Current Profile Content:" -ForegroundColor Cyan
    Write-Host $profileStatus.Content -ForegroundColor Gray
}

# Recommendations
Write-Host ""
Write-Host "Recommendations:" -ForegroundColor Yellow

if ($repoIssues.Count -gt 0) {
    Write-Host "  1. Fix repository structure issues first" -ForegroundColor Red
    
    if (-not (Test-Path $repoProfilesDir)) {
        Write-Host "     Run: New-Item -Path '$repoProfilesDir' -ItemType Directory -Force" -ForegroundColor Gray
    }
    
    if (-not (Test-Path $repoScriptsDir)) {
        Write-Host "     Run: New-Item -Path '$repoScriptsDir' -ItemType Directory -Force" -ForegroundColor Gray
    }
} else {
    if (-not $profileStatus.Exists) {
        Write-Host "  1. Create profile loader script" -ForegroundColor Yellow
        Write-Host "     Action: Create new loader profile" -ForegroundColor Gray
    } elseif (-not $profileStatus.IsLoader) {
        Write-Host "  1. Current profile is not a loader script" -ForegroundColor Yellow
        Write-Host "     Action: Backup current profile and replace with loader" -ForegroundColor Gray
    } elseif (-not $profileStatus.PointsToRepo) {
        Write-Host "  1. Profile loader points to wrong repository" -ForegroundColor Yellow
        Write-Host "     Action: Update loader to point to correct repository" -ForegroundColor Gray
    } elseif (-not $profileStatus.InSync) {
        Write-Host "  1. Profile loader is out of sync" -ForegroundColor Yellow
        Write-Host "     Action: Update loader script" -ForegroundColor Gray
    } else {
        Write-Host "  ✓ Profile is properly configured and in sync!" -ForegroundColor Green
    }
}

# Action functions
function Backup-CurrentProfile {
    if (Test-Path $currentProfile) {
        $backupPath = "$currentProfile.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $currentProfile $backupPath
        Write-Host "Backed up current profile to: $backupPath" -ForegroundColor Green
        return $backupPath
    }
    return $null
}

function Install-LoaderProfile {
    param([bool]$CreateBackup = $true)
    
    if ($CreateBackup) {
        $backup = Backup-CurrentProfile
    }
    
    # Ensure profile directory exists
    if (-not (Test-Path $currentProfileDir)) {
        New-Item -Path $currentProfileDir -ItemType Directory -Force
        Write-Host "Created profile directory: $currentProfileDir" -ForegroundColor Green
    }
    
    # Install the loader
    $loaderContent = Get-LoaderScript
    
    if ($DryRun) {
        Write-Host "DRY RUN: Would install loader profile to: $currentProfile" -ForegroundColor Yellow
    } else {
        Set-Content -Path $currentProfile -Value $loaderContent -Force
        Write-Host "Installed loader profile to: $currentProfile" -ForegroundColor Green
    }
}

# Interactive actions
if ($repoIssues.Count -eq 0 -and (-not $profileStatus.InSync -or -not $profileStatus.Exists)) {
    Write-Host ""
    if (-not $Force) {
        $response = Read-Host "Would you like to fix the profile? (y/n)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Install-LoaderProfile
        }
    } else {
        Install-LoaderProfile
    }
}

Write-Host ""
Write-Host "Profile management complete!" -ForegroundColor Green
Write-Host "To enable verbose profile loading, set: " -NoNewline -ForegroundColor Cyan
Write-Host "`$env:POWERSHELL_PROFILE_VERBOSE = '1'" -ForegroundColor Yellow