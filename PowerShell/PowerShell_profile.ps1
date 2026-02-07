# --- Loader ---
$remotePath = "C:\repositories\local-configs\PowerShell\profile_remote.ps1"

if (Test-Path $remotePath) { 
    . $remotePath 
} else {
    Write-Warning "Remote profile not found at $remotePath"
}

# --- Prompt Logic (User/Admin Awareness) ---
function prompt {
    $user = [Environment]::UserName
    $color = if ($user -match "admin") { "Red" } else { "Cyan" }
    $prefix = if ($user -match "admin") { "[ADMIN] " } else { "" }
    
    Write-Host "$prefix$user" -ForegroundColor $color -NoNewline
    Write-Host " $(Get-Location) " -NoNewline
    return "> "
}