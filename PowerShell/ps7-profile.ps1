# PowerShell 7 Specific Profile
# GitHub: Jeenil/local-configs

# PS7-specific modules
# Import-Module SomePS7Module

# PS7-specific aliases and functions
function Get-PS7Only {
    Write-Host "This function only works in PowerShell 7" -ForegroundColor Cyan
}

# PS7 specific features
$PSStyle.FileInfo.Directory = "e[34;1m"

# Basic Functions
function ll { Get-ChildItem -Force | Format-Table -Property Mode, LastWriteTime, Length, Name -AutoSize }

# Custom user paths

# To get to the Root of the Repo Dir. -Option AllScope choice since it ensures your aliases work consistently throughout your entire session, regardless of what scripts you run or functions you call.
Set-Alias -Name r -Value Set-Location -Option AllScope
Set-Variable -Name DevOpsPath -Value "C:\repositories" -Option AllScope

# Create function to change to DevOps directory
function GoToDevOps { Set-Location $DevOpsPath }

# Set alias to use the function
Set-Alias -Name r -Value GoToDevOps -Option AllScope


# To get to the OneDriveDocumnets of the Repo Dir. -Option AllScope choice since it ensures your aliases work consistently throughout your entire session, regardless of what scripts you run or functions you call.

Set-Alias -Name h -Value Set-Location -Option AllScope
Set-Variable -Name OneDriveDocuments -Value "C:\Users\jeepatel\OneDrive - LogixHealth Inc\Documents" -Option AllScope

# Create function to change to DevOps directory
function GoToDocuments { Set-Location $OneDriveDocuments }

# Set alias to use the function
Set-Alias -Name h -Value GoToDocuments -Option AllScope