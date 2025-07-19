# PowerShell 7 Specific Profile
# Only PS7-specific settings go here

# PS7 specific styling
if ($PSStyle) {
    $PSStyle.FileInfo.Directory = "`e[34;1m"
}

# Enhanced predictions in PS7
if (Get-Module -Name PSReadLine) {
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
}
