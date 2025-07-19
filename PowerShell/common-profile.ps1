# Common PowerShell Profile - Works everywhere (PS5/PS7, Work/Personal)
# GitHub: Jeenil/local-configs

# ====================
# Environment Detection
# ====================
$isWorkMachine = $env:USERDOMAIN -match "LogixHealth|LOGIX" -or $env:USERNAME -eq "jeepatel"
$isPersonalMachine = -not $isWorkMachine
$isPowerShell7 = $PSVersionTable.PSVersion.Major -ge 7

# Display environment
$envType = if ($isWorkMachine) { "Work" } else { "Personal" }
$psVersion = "PS$($PSVersionTable.PSVersion.Major)"
Write-Host "$psVersion - $envType Environment" -ForegroundColor Green

# ====================
# Common Aliases
# ====================
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name which -Value Get-Command
Set-Alias -Name grep -Value Select-String
Set-Alias -Name touch -Value New-Item

# ====================
# Common Functions
# ====================
function ll { 
    Get-ChildItem -Force | Format-Table -Property Mode, LastWriteTime, Length, Name -AutoSize 
}

function la { 
    Get-ChildItem -Force -Hidden 
}

function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location -Path $Path
}

function up {
    param([int]$Count = 1)
    $Path = (Get-Location).Path
    for ($i = 0; $i -lt $Count; $i++) {
        $Path = Split-Path -Parent $Path
    }
    Set-Location -Path $Path
}

function e {
    param([string]$Path = ".")
    explorer.exe (Resolve-Path $Path).Path
}

# ====================
# Navigation Functions
# ====================
function repos { 
    if ($isPersonalMachine) {
        Set-Location "C:\repositories"
    } else {
        Set-Location "C:\repos"  # Adjust if your work uses different path
    }
}

function home { 
    Set-Location $env:USERPROFILE 
}

function desktop { 
    Set-Location "$env:USERPROFILE\Desktop" 
}

function downloads { 
    Set-Location "$env:USERPROFILE\Downloads" 
}

# Work-specific navigation
if ($isWorkMachine) {
    function docs { 
        Set-Location "$env:USERPROFILE\OneDrive - LogixHealth Inc\Documents" 
    }
    Set-Alias -Name h -Value docs
    
    function work {
        Set-Location "C:\Work"
    }
} else {
    # Personal-specific navigation
    function docs { 
        Set-Location "$env:USERPROFILE\OneDrive\Documents" 
    }
    Set-Alias -Name h -Value docs
    
    function projects {
        Set-Location "$env:USERPROFILE\projects"
    }
}

# Shortcut to repos
Set-Alias -Name r -Value repos

# ====================
# Utility Functions
# ====================
function Update-Profile {
    $repoPath = if ($isPersonalMachine) { "C:\repositories\local-configs" } else { "C:\repos\local-configs" }
    
    if (Test-Path $repoPath) {
        Push-Location $repoPath
        git pull
        . $PROFILE
        Pop-Location
        Write-Host "Profile updated and reloaded!" -ForegroundColor Green
    } else {
        Write-Host "Repository not found at: $repoPath" -ForegroundColor Red
        Write-Host "Clone it first using: git clone https://github.com/Jeenil/local-configs.git '$repoPath'" -ForegroundColor Yellow
    }
}

function Get-MyIP {
    try {
        $publicIP = (Invoke-WebRequest -Uri "https://api.ipify.org?format=text" -UseBasicParsing).Content.Trim()
        $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*"}).IPAddress | Select-Object -First 1
        
        Write-Host "Local IP:  $localIP" -ForegroundColor Cyan
        Write-Host "Public IP: $publicIP" -ForegroundColor Green
    } catch {
        Write-Host "Error getting IP information" -ForegroundColor Red
    }
}

function Show-Commands {
    Write-Host "`nAvailable Commands:" -ForegroundColor Yellow
    Write-Host "==================" -ForegroundColor Yellow
    
    Write-Host "`nNavigation:" -ForegroundColor Cyan
    Write-Host "  r, repos     - Go to repositories folder" -ForegroundColor Gray
    Write-Host "  h, docs      - Go to Documents folder" -ForegroundColor Gray
    Write-Host "  home         - Go to user home" -ForegroundColor Gray
    Write-Host "  desktop      - Go to Desktop" -ForegroundColor Gray
    Write-Host "  downloads    - Go to Downloads" -ForegroundColor Gray
    if ($isPersonalMachine) {
        Write-Host "  projects     - Go to projects folder" -ForegroundColor Gray
    } else {
        Write-Host "  work         - Go to work folder" -ForegroundColor Gray
    }
    
    Write-Host "`nUtilities:" -ForegroundColor Cyan
    Write-Host "  ll           - List files (detailed)" -ForegroundColor Gray
    Write-Host "  la           - List all (including hidden)" -ForegroundColor Gray
    Write-Host "  mkcd         - Create and enter directory" -ForegroundColor Gray
    Write-Host "  up [n]       - Go up n directories" -ForegroundColor Gray
    Write-Host "  e            - Open Explorer here" -ForegroundColor Gray
    Write-Host "  which        - Find command location" -ForegroundColor Gray
    Write-Host "  Get-MyIP     - Show IP addresses" -ForegroundColor Gray
    Write-Host "  Update-Profile - Update and reload profile" -ForegroundColor Gray
}

Set-Alias -Name help-me -Value Show-Commands

# ====================
# Custom Prompt
# ====================
function prompt {
    $location = Split-Path -Leaf (Get-Location)
    $fullPath = (Get-Location).Path
    
    # Show full path if we're in a short name directory
    if ($location.Length -le 3) {
        $location = $fullPath
    }
    
    # Build prompt
    Write-Host "$psVersion " -NoNewline -ForegroundColor DarkGray
    Write-Host "$env:USERNAME" -NoNewline -ForegroundColor $(if ($isWorkMachine) { "Yellow" } else { "Cyan" })
    Write-Host "@" -NoNewline -ForegroundColor DarkGray
    Write-Host "$env:COMPUTERNAME " -NoNewline -ForegroundColor Green
    Write-Host $location -NoNewline -ForegroundColor Blue
    return "> "
}

# ====================
# Module Imports
# ====================
Import-Module -Name PSReadLine -ErrorAction SilentlyContinue

# Tab completion
if (Get-Module -Name PSReadLine) {
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadlineOption -ShowToolTips -ErrorAction SilentlyContinue
    Set-PSReadlineOption -HistorySearchCursorMovesToEnd -ErrorAction SilentlyContinue
}

# ====================
# Welcome Message
# ====================
Write-Host "Type 'help-me' to see available commands" -ForegroundColor DarkGray