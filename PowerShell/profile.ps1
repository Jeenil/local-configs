# profile.ps1 - Universal PowerShell Profile
# Works with both PowerShell 5 and 7

# Core Settings
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
Set-Location C:\

# Better Prompt
function prompt {
    $path = (Get-Location).Path.Replace($HOME, "~")
    Write-Host "PS " -NoNewline -ForegroundColor DarkGray
    Write-Host $path -NoNewline -ForegroundColor Cyan
    Write-Host " >" -NoNewline -ForegroundColor DarkGray
    return " "
}

# Universal Aliases (work in both PS5 & PS7)
Set-Alias ll Get-ChildItem
Set-Alias which Get-Command
Set-Alias grep Select-String
Set-Alias touch New-Item

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function ~ { Set-Location $HOME }
function repos { 
    $repoPath = if (Test-Path "C:\repos") { "C:\repos" } else { "C:\repositories" }
    Set-Location $repoPath 
}

# Git Shortcuts
function gs { git status }
function ga { git add . }
function gc { param($m) git commit -m $m }
function gp { git push }
function gl { git log --oneline -10 }
function gco { param($branch) git checkout $branch }

# Version-specific features (handles both PS5 & PS7)
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # PS7+ specific features
    if ($PSStyle) {
        $PSStyle.FileInfo.Directory = $PSStyle.Foreground.Blue + $PSStyle.Bold
        $PSStyle.FileInfo.Executable = $PSStyle.Foreground.Green
    }
} else {
    # PS5 compatibility
    # Add any PS5-specific settings here if needed
}

# Load additional functions if they exist
$functionsPath = Join-Path $PSScriptRoot "functions.ps1"
if (Test-Path $functionsPath) { . $functionsPath }

# Load work-specific settings if on work machine
if ($env:USERDOMAIN -match "LogixHealth|LOGIX") {
    $workPath = Join-Path $PSScriptRoot "work-specific.ps1"
    if (Test-Path $workPath) { . $workPath }
}

# Welcome message
Write-Host "PowerShell $($PSVersionTable.PSVersion) - Profile Loaded" -ForegroundColor Green