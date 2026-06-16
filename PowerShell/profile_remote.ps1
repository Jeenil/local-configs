# ==========================================================
# REMOTE PROFILE - DevOps & Git Optimized (Shared Admin/User)
# ==========================================================

# --- 1. THE "MEMORY" (History Search & Prediction) ---
# This mimics the 'fish' or 'zsh' behavior from your Linux tools
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine
    # Show gray "ghost text" predictions from your history
    Set-PSReadLineOption -PredictionSource History
    # Press F2 to toggle between inline view and list view
    Set-PSReadLineOption -PredictionViewStyle ListView
    # Keybind: Use UpArrow to search history for what you've already typed
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# --- 2. PATH & ENVIRONMENT ---
function Add-PathDirectory {
    param([string]$Directory)
    if ((Test-Path $Directory) -and ($env:Path -notlike "*$Directory*")) {
        $env:Path = "$env:Path;$Directory"
    }
}

# Fix self-signed certs for LogixHealth
$certPaths = @("C:\tls\BEDROOTCA001.crt", "C:\_IT\tls\BEDROOTCA001.crt")
foreach ($cp in $certPaths) {
    if (Test-Path $cp) {
        $env:COMPANY_CERT_PATH = $cp
        $env:NODE_EXTRA_CA_CERTS = $cp
        $env:CURL_CA_BUNDLE = $cp
        break
    }
}

# --- 3. NAVIGATION ---
Set-Alias -Name ll -Value Get-ChildItem
function r { Set-Location "C:\repositories" }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

# --- GIT COMMANDS (Safe Guarded) ---
if (Get-Command git -ErrorAction SilentlyContinue) {
    
    # 1. Clear the built-in PowerShell 'gc' (Get-Content) alias
    if (Test-Path Alias:gc) { Remove-Item Alias:gc -Force }

    # 2. Re-assign your Git Aliases
    function gs  { git status --short --branch }
    function ga  { git add $args }
    function gaa { git add --all }
    
    # Updated Commit Function to handle messages properly
    function gc { 
        if ($args) {
            git commit -m "$($args -join ' ')" 
        } else {
            git commit # Opens your default editor if no message provided
        }
    }

    function gca { git commit --amend --no-edit }
    function gp  { git pull --rebase }
    function gu  { git push }
    function gl  { git log --oneline --graph --decorate --all }
}

# --- 5. KUBERNETES & TERRAFORM ---
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    Set-Alias -Name k -Value kubectl
    function kgp { kubectl get pods @args }
    function kgd { kubectl get deployments @args }
    function kdp { kubectl describe pod @args }
}

if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Set-Alias -Name tf -Value terraform
    function ti  { terraform init @args }
    function tp  { terraform plan @args }
    function ta  { terraform apply -auto-approve }
}

# --- 6. UTILS ---
function reload { . $PROFILE; Write-Host "Profile Reloaded!" -ForegroundColor Magenta }

oh-my-posh init pwsh | Invoke-Expression

# --- 7. LOAD NOTIFY ---
$time = Get-Date -Format 'HH:mm'
Write-Host "DevOps Profile Loaded [$time]" -ForegroundColor Green