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
function New-GitBranch { param([Parameter(Mandatory)][string]) git checkout -b  }
Set-Alias -Name gnb -Value New-GitBranch
function Switch-GitBranch { param([Parameter(Mandatory)][string]) git checkout  }
Set-Alias -Name gsw -Value Switch-GitBranch
function Push-GitChanges { git push }
Set-Alias -Name gp -Value Push-GitChanges
function Add-GitChanges { git add . }
Set-Alias -Name ga -Value Add-GitChanges
function Commit-GitChanges { param([Parameter(Mandatory)][string]) git commit -m  }
Set-Alias -Name gcm -Value Commit-GitChanges

function Update-Profile {
    Push-Location "C:\repositories\local-configs"
    git pull
    . $PROFILE
    Pop-Location
    Write-Host "Profile updated and reloaded!" -ForegroundColor Green
}

# Custom prompt
function prompt {
    $version = $PSVersionTable.PSVersion.Major
    $location = $(Get-Location).Path
    Write-Host "PS[$version] " -NoNewline -ForegroundColor Green
    Write-Host "$location" -NoNewline -ForegroundColor Blue
    return " > "
}
