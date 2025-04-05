# Example-Script.ps1
# This script will be automatically loaded by both PS5 and PS7 profiles

function Get-HelloWorld {
    param(
        [string] = "World"
    )
    
    Write-Host "Hello, !" -ForegroundColor Cyan
}
