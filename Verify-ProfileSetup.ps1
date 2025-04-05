# Verify-ProfileSetup.ps1
# Verifies that both PS5 and PS7 profiles point to the same repository location

Write-Host "Profile Verification Tool" -ForegroundColor Cyan
Write-Host "------------------------" -ForegroundColor Cyan

# Current PowerShell version
$currentVersion = $PSVersionTable.PSVersion.Major
Write-Host "Current PowerShell version: $currentVersion" -ForegroundColor Yellow

# Current profile path
Write-Host "Current profile path: $PROFILE" -ForegroundColor Yellow

# Check if profile exists
if (Test-Path $PROFILE) {
    Write-Host "Profile exists: Yes" -ForegroundColor Green
    
    # Get the content of the profile
    $profileContent = Get-Content $PROFILE -Raw
    
    # Check if the repository path is in the profile
    if ($profileContent -like "*C:\repositories\local-configs*") {
        Write-Host "Repository path found in profile: Yes" -ForegroundColor Green
        Write-Host "Repository path: C:\repositories\local-configs" -ForegroundColor Green
    } else {
        Write-Host "Repository path found in profile: No" -ForegroundColor Red
        Write-Host "Please run Setup-PowerShellProfiles.ps1 to fix this" -ForegroundColor Red
    }
} else {
    Write-Host "Profile exists: No" -ForegroundColor Red
    Write-Host "Please run Setup-PowerShellProfiles.ps1 to create the profile" -ForegroundColor Red
}

# Check if repository files exist
$powershellDir = Join-Path "C:\repositories\local-configs" "PowerShell"
$commonProfilePath = Join-Path $powershellDir "common-profile.ps1"
$versionSpecificPath = Join-Path $powershellDir "ps$currentVersion-profile.ps1"

if (Test-Path $commonProfilePath) {
    Write-Host "Common profile exists: Yes" -ForegroundColor Green
} else {
    Write-Host "Common profile exists: No" -ForegroundColor Red
}

if (Test-Path $versionSpecificPath) {
    Write-Host "PS$currentVersion profile exists: Yes" -ForegroundColor Green
} else {
    Write-Host "PS$currentVersion profile exists: No" -ForegroundColor Red
}

Write-Host "
If any issues were found, please run Setup-PowerShellProfiles.ps1 to fix them" -ForegroundColor Yellow
