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
        }
        catch {}
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
function repos {
    $repoPath = if (Test-Path "C:\repos") { "C:\repos" } else { "C:\repositories" }
    Set-Location $repoPath
}
function desktop { Set-Location "$HOME\Desktop" }
function downloads { Set-Location "$HOME\Downloads" }
function docs { Set-Location "$HOME\Documents" }

# Git Shortcuts
function gs { git status }
function ga { git add . }
function gc { param($m) git commit -m $m }
function gp { git push }
function gl { git log --oneline -10 }
function gco { param($branch) git checkout $branch }
function gb { git branch }
function gpl { git pull }

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

# Enhanced help function
function help-me {
    Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║       PowerShell Commands Help        ║" -ForegroundColor Magenta
    Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Magenta

    Write-Host "`n📁 Navigation:" -ForegroundColor Yellow
    Write-Host "  repos      → Go to repositories folder" -ForegroundColor Gray
    Write-Host "  desktop    → Go to Desktop" -ForegroundColor Gray
    Write-Host "  downloads  → Go to Downloads" -ForegroundColor Gray
    Write-Host "  ..         → Go up one directory" -ForegroundColor Gray
    Write-Host "  ...        → Go up two directories" -ForegroundColor Gray

    Write-Host "`n🔧 Git Commands:" -ForegroundColor Yellow
    Write-Host "  gs         → git status" -ForegroundColor Gray
    Write-Host "  ga         → git add ." -ForegroundColor Gray
    Write-Host "  gc 'msg'   → git commit -m 'msg'" -ForegroundColor Gray
    Write-Host "  gp         → git push" -ForegroundColor Gray
    Write-Host "  gpl        → git pull" -ForegroundColor Gray
    Write-Host "  gl         → git log (last 10)" -ForegroundColor Gray
    Write-Host "  gb         → git branch" -ForegroundColor Gray
    Write-Host "  gco branch → git checkout branch" -ForegroundColor Gray

    Write-Host "`n🛠️ Utilities:" -ForegroundColor Yellow
    Write-Host "  ll         → List files (Get-ChildItem)" -ForegroundColor Gray
    Write-Host "  which cmd  → Find command location" -ForegroundColor Gray
    Write-Host "  grep       → Search in files" -ForegroundColor Gray
    Write-Host "  touch file → Create empty file" -ForegroundColor Gray
    Write-Host "  mkcd dir   → Create and enter directory" -ForegroundColor Gray
    Write-Host "  sysinfo    → Show system information" -ForegroundColor Gray
    Write-Host "  reload     → Reload PowerShell profile" -ForegroundColor Gray

    Write-Host "`n💡 Tips:" -ForegroundColor Yellow
    Write-Host "  - Tab completion works everywhere!" -ForegroundColor DarkGray
    Write-Host "  - Use Ctrl+R to search command history" -ForegroundColor DarkGray
    Write-Host "  - Type 'help <command>' for detailed help" -ForegroundColor DarkGray
    Write-Host ""
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
function la {
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
    }
    catch {
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

"@ -ForegroundColor Cyan

Write-Host "PowerShell $($PSVersionTable.PSVersion.ToString()) Ready!" -ForegroundColor Green
Write-Host "Type 'help-me' for available commands" -ForegroundColor DarkGray
Write-Host ""