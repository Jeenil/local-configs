# profile.ps1 - Universal PowerShell Profile
# Works with both PowerShell 5 and 7

# Core Settings
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
Set-Location C:\

# Better Prompt with Git support
function prompt {
    $path = (Get-Location).Path.Replace($HOME, "~")
    $gitBranch = ""
    
    # Check if we're in a git repo
    if (Test-Path .git) {
        try {
            $branch = git branch --show-current 2>$null
            if ($branch) {
                $gitBranch = " [$branch]"
            }
        } catch {}
    }
    
    Write-Host "PS " -NoNewline -ForegroundColor DarkGray
    Write-Host $path -NoNewline -ForegroundColor Cyan
    Write-Host $gitBranch -NoNewline -ForegroundColor Yellow
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
function r {
    $repoPath = if (Test-Path "C:\repos") { "C:\repos" } else { "C:\repositories" }
    Set-Location $repoPath
}

# Terraform shortcuts
function ti { terraform init }
function ta { terraform apply }
function td { terraform destroy }
function tf { terraform fmt }
function tv { terraform validate }
function tc {
    # Terraform clean
    Remove-Item -Recurse -Force .terraform -ErrorAction SilentlyContinue
    Remove-Item -Force terraform.tfstate* -ErrorAction SilentlyContinue
    Remove-Item -Force .terraform.lock.hcl -ErrorAction SilentlyContinue
}

# System Info and Utilities
function sysinfo {
    Write-Host "`n═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  System Information" -ForegroundColor White
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Computer     : $env:COMPUTERNAME" -ForegroundColor Green
    Write-Host "User         : $env:USERNAME" -ForegroundColor Green
    Write-Host "Domain       : $env:USERDOMAIN" -ForegroundColor Green
    Write-Host "PowerShell   : $($PSVersionTable.PSVersion)" -ForegroundColor Green
    Write-Host "OS           : $(Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption)" -ForegroundColor Green
    Write-Host "Uptime       : $((Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime)" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════`n" -ForegroundColor Cyan
}

# Quick file operations
function mkcd { 
    param($dir) 
    mkdir $dir -ErrorAction SilentlyContinue
    cd $dir 
}

# Reload profile
function reload {
    Write-Host "Reloading profile..." -ForegroundColor Yellow
    . $PROFILE
    Write-Host "✓ Profile reloaded!" -ForegroundColor Green
}

# Pretty directory listing
function ll {
    Get-ChildItem -Force | Format-Table Mode, LastWriteTime, Length, Name -AutoSize
}

# Search functions
function find-file {
    param([string]$name)
    Write-Host "Searching for '$name'..." -ForegroundColor Yellow
    Get-ChildItem -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$name*" }
}

function find-text {
    param([string]$pattern, [string]$path = ".")
    Write-Host "Searching for '$pattern' in $path..." -ForegroundColor Yellow
    Get-ChildItem -Path $path -Recurse -File | Select-String -Pattern $pattern
}

# Quick calculations
function calc {
    param([string]$expression)
    try {
        $result = Invoke-Expression $expression
        Write-Host "$expression = " -NoNewline -ForegroundColor Gray
        Write-Host $result -ForegroundColor Green
    } catch {
        Write-Host "Invalid expression" -ForegroundColor Red
    }
}

# Version-specific features (handles both PS5 & PS7)
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # PS7+ specific features
    if ($PSStyle) {
        $PSStyle.FileInfo.Directory = $PSStyle.Foreground.Blue + $PSStyle.Bold
        $PSStyle.FileInfo.Executable = $PSStyle.Foreground.Green
        $PSStyle.FileInfo.SymbolicLink = $PSStyle.Foreground.Cyan
    }
    
    # Tab completion improvements for PS7
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}
else {
    # PS5 compatibility
    # Tab completion for PS5
    Set-PSReadLineKeyHandler -Key Tab -Function Complete
}

# Common PSReadLine settings (both PS5 & PS7)
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Load additional functions if they exist
$functionsPath = Join-Path $PSScriptRoot "functions.ps1"
if (Test-Path $functionsPath) { . $functionsPath }

# Load work-specific settings if on work machine
if ($env:USERDOMAIN -match "LogixHealth|LOGIX") {
    $workPath = Join-Path $PSScriptRoot "work-specific.ps1"
    if (Test-Path $workPath) { . $workPath }
}

# Welcome message with ASCII art
Clear-Host
Write-Host @"
    ____                          _____ __         ____
   / __ \____ _      _____  _____/ ___// /_  ___  / / /
  / /_/ / __ \ | /| / / _ \/ ___/\__ \/ __ \/ _ \/ / / 
 / ____/ /_/ / |/ |/ /  __/ /   ___/ / / / /  __/ / /  
/_/    \____/|__/|__/\___/_/   /____/_/ /_/\___/_/_/  

Jeenil Patel V-1.0
                                                        
"@ -ForegroundColor Cyan

Write-Host "PowerShell $($PSVersionTable.PSVersion.ToString()) Ready!" -ForegroundColor Green
Write-Host "Type 'help-me' for available commands" -ForegroundColor DarkGray
Write-Host ""