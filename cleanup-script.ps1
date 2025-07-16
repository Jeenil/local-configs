# Cleanup-PowerShellProfiles.ps1
# This script removes the profiles created by Fix-PowerShellProfiles.ps1
# Run with administrator privileges if possible

Write-Host "PowerShell Profile Cleanup Script" -ForegroundColor Yellow
Write-Host "This will remove the auto-generated profile files" -ForegroundColor Yellow
Write-Host ""

# Define the profile paths that were created by the original script
$ps5ProfilePath = "$env:USERPROFILE\OneDrive - LogixHealth Inc\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$ps7ProfilePath = "$env:USERPROFILE\OneDrive - LogixHealth Inc\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# Repository path used in the original script
$repoLocalPath = "C:\repositories\local-configs"
$manualInstructionsPath = Join-Path $repoLocalPath "Manual-Profile-Setup.txt"

Write-Host "Checking for profile files to remove..." -ForegroundColor Cyan

# Function to safely remove a file with confirmation
function Remove-ProfileFile {
    param(
        [string]$FilePath,
        [string]$ProfileType
    )
    
    if (Test-Path $FilePath) {
        Write-Host "Found $ProfileType profile: $FilePath" -ForegroundColor Yellow
        
        # Check if it's the auto-generated profile by looking for the signature
        $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
        if ($content -and $content.Contains("Auto-generated on") -and $content.Contains("PowerShell Profile Loader")) {
            Write-Host "This appears to be an auto-generated profile" -ForegroundColor Green
            
            $response = Read-Host "Remove this profile? (y/n)"
            if ($response -eq 'y' -or $response -eq 'Y') {
                try {
                    Remove-Item $FilePath -Force
                    Write-Host "Removed $ProfileType profile" -ForegroundColor Green
                } catch {
                    Write-Host "Error removing $ProfileType profile: $_" -ForegroundColor Red
                }
            } else {
                Write-Host "Skipped $ProfileType profile" -ForegroundColor Yellow
            }
        } else {
            Write-Host "This profile doesn't appear to be auto-generated (skipping)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "$ProfileType profile not found: $FilePath" -ForegroundColor Gray
    }
}

# Remove the profile files
Remove-ProfileFile -FilePath $ps5ProfilePath -ProfileType "PowerShell 5"
Remove-ProfileFile -FilePath $ps7ProfilePath -ProfileType "PowerShell 7"

# Remove manual instructions file if it exists
if (Test-Path $manualInstructionsPath) {
    Write-Host "Found manual instructions file: $manualInstructionsPath" -ForegroundColor Yellow
    $response = Read-Host "Remove manual instructions file? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        try {
            Remove-Item $manualInstructionsPath -Force
            Write-Host "Removed manual instructions file" -ForegroundColor Green
        } catch {
            Write-Host "Error removing manual instructions file: $_" -ForegroundColor Red
        }
    }
}

# Check if profile directories are empty and offer to remove them
$ps5ProfileDir = Split-Path -Parent $ps5ProfilePath
$ps7ProfileDir = Split-Path -Parent $ps7ProfilePath

function Remove-EmptyProfileDirectory {
    param(
        [string]$DirPath,
        [string]$ProfileType
    )
    
    if (Test-Path $DirPath) {
        $items = Get-ChildItem $DirPath -Force
        if ($items.Count -eq 0) {
            Write-Host "$ProfileType directory is empty: $DirPath" -ForegroundColor Yellow
            $response = Read-Host "Remove empty directory? (y/n)"
            if ($response -eq 'y' -or $response -eq 'Y') {
                try {
                    Remove-Item $DirPath -Force
                    Write-Host "Removed empty $ProfileType directory" -ForegroundColor Green
                } catch {
                    Write-Host "Error removing $ProfileType directory: $_" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "$ProfileType directory contains other files (not removing)" -ForegroundColor Cyan
        }
    }
}

Remove-EmptyProfileDirectory -DirPath $ps5ProfileDir -ProfileType "PowerShell 5"
Remove-EmptyProfileDirectory -DirPath $ps7ProfileDir -ProfileType "PowerShell 7"

Write-Host ""
Write-Host "Cleanup complete!" -ForegroundColor Green
Write-Host "You may need to restart PowerShell sessions for changes to take effect." -ForegroundColor Cyan