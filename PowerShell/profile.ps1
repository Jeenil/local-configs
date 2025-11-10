# profile.ps1 - Universal PowerShell Profile
# Works with PowerShell 5, 6, and 7 on Windows, Mac, and Linux

# Core Settings
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
Set-Location $HOME

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

# Cross-platform repository directory
function r {
    $repoPaths = @(
        "C:\Repositories",
        "C:\repos",
        "$HOME\Repositories",
        "$HOME\repositories",
        "/c/repositories",
        "/c/repos"
    )
    
    foreach ($path in $repoPaths) {
        if (Test-Path $path) {
            Set-Location $path
            return
        }
    }
    
    Write-Host "No repositories directory found. Checked:" -ForegroundColor Yellow
    $repoPaths | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
}

function desktop { Set-Location "$HOME\Desktop" }
function downloads { Set-Location "$HOME\Downloads" }
function docs { Set-Location "$HOME\Documents" }

# Helper Functions
function Get-IsGitRepo {
    try {
        git rev-parse --is-inside-work-tree 2>$null | Out-Null
        return $?
    }
    catch {
        return $false
    }
}

function Get-MainBranchName {
    if (git show-ref --verify --quiet refs/heads/main) {
        return "main"
    }
    elseif (git show-ref --verify --quiet refs/heads/master) {
        return "master"
    }
    else {
        Write-Host "Error: No 'main' or 'master' branch found" -ForegroundColor Red
        return $null
    }
}

function Get-IsGitHub {
    $remoteUrl = git config --get remote.origin.url 2>$null
    return $remoteUrl -match "github\.com"
}

# Git Shortcuts (Basic)
function ga { git add $args }
function gaa { git add --all }
function gd { git diff }
function gl { git log }
function glg { 
    git log --graph --pretty=format:'%C(yellow)%h%Creset %C(cyan)%d%Creset %C(white)%s%Creset %C(green)(%an)%Creset%n%w(0,8,8)%b%Creset' --all --decorate 
}
function gp { git pull --rebase }
function grb { git rebase $args }
function grba { git rebase --abort }
function grs { git reset $args }
function grsh { git reset --hard }
function grva { git revert --abort }
function gs { git status --porcelain }
function gst { git stash }
function gstd { git stash drop }
function gstl { git stash list }
function gstp { git stash pop }
function gswc { git switch -c $args }
function gu { git push }
function guf { git push --force }

# gb - Create new branch with auto-naming
function gb {
    param(
        [string]$description = "misc",
        [string]$appName = "misc"
    )
    
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    $isGitHub = Get-IsGitHub
    $username = if ($env:USER) { $env:USER } else { $env:USERNAME }
    
    $branchName = if ($isGitHub) { 
        $description 
    }
    else { 
        "feature/$appName/$username/$description" 
    }
    
    # Stash if needed
    $status = git status --porcelain
    if ($status) {
        Write-Host "Stashing changes..." -ForegroundColor Yellow
        git stash push -m "Auto-stash before creating new branch"
    }
    
    # Find and switch to main branch
    $mainBranch = Get-MainBranchName
    if (-not $mainBranch) { return }
    
    $currentBranch = git branch --show-current
    if ($currentBranch -ne $mainBranch) {
        git switch $mainBranch
    }
    
    git pull --rebase
    git switch --create $branchName
    git push
    
    # Pop stash if exists
    $stashCount = (git stash list | Measure-Object).Count
    if ($stashCount -gt 0) {
        Write-Host "Applying stashed changes..." -ForegroundColor Yellow
        git stash pop
    }
    
    Write-Host ""
    gbl
}

# gbc - Clean merged/gone branches
function gbc {
    param([switch]$SkipFetch)
    
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    $mainBranch = Get-MainBranchName
    if (-not $mainBranch) { return }
    
    $currentBranch = git branch --show-current
    if ($currentBranch -ne $mainBranch) {
        git switch $mainBranch
    }
    
    if (-not $SkipFetch) {
        git fetch --prune --quiet
    }
    
    # Delete branches marked as gone
    $branches = git branch -vv | Where-Object { $_ -match ": gone]" }
    foreach ($line in $branches) {
        if ($line -match '^\s*(\S+)') {
            $branchName = $matches[1]
            git branch --delete --force $branchName
            Write-Host "Deleted branch: $branchName" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    gbl
}

# gbd - Delete branch (local and remote)
function gbd {
    param([string]$branchOrNumber)
    
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    if (-not $branchOrNumber) {
        Write-Host "Error: Branch name or number required" -ForegroundColor Red
        return
    }
    
    # If number, get branch name from list
    if ($branchOrNumber -match '^\d+$') {
        $branches = git branch --format="%(refname:short)" | Sort-Object
        $index = [int]$branchOrNumber - 1
        if ($index -ge 0 -and $index -lt $branches.Count) {
            $branchName = $branches[$index]
        }
        else {
            Write-Host "Error: Branch number $branchOrNumber does not exist" -ForegroundColor Red
            return
        }
    }
    else {
        $branchName = $branchOrNumber
    }
    
    # Delete local
    if (git show-ref --verify --quiet "refs/heads/$branchName") {
        git branch --delete --force $branchName
        Write-Host "Deleted branch '$branchName' locally" -ForegroundColor Green
    }
    
    # Delete remote
    $remoteBranches = git ls-remote --heads origin $branchName 2>$null
    if ($remoteBranches) {
        git push origin ":$branchName"
        Write-Host "Deleted branch '$branchName' remotely" -ForegroundColor Green
    }
    
    Write-Host ""
    gbl
}

# gbdl - Delete branch (local only)
function gbdl {
    param([string]$branchOrNumber)
    
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    if (-not $branchOrNumber) {
        Write-Host "Error: Branch name or number required" -ForegroundColor Red
        return
    }
    
    # If number, get branch name from list
    if ($branchOrNumber -match '^\d+$') {
        $branches = git branch --format="%(refname:short)" | Sort-Object
        $index = [int]$branchOrNumber - 1
        if ($index -ge 0 -and $index -lt $branches.Count) {
            $branchName = $branches[$index]
        }
        else {
            Write-Host "Error: Branch number $branchOrNumber does not exist" -ForegroundColor Red
            return
        }
    }
    else {
        $branchName = $branchOrNumber
    }
    
    if (git show-ref --verify --quiet "refs/heads/$branchName") {
        git branch --delete --force $branchName
        Write-Host "Deleted branch '$branchName' locally" -ForegroundColor Green
    }
    else {
        Write-Host "Warning: Branch '$branchName' does not exist locally" -ForegroundColor Yellow
    }
    
    Write-Host ""
    gbl
}

# gbl - List branches with numbers
function gbl {
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    $branches = git branch --format="%(refname:short)" | Sort-Object
    $currentBranch = git branch --show-current
    
    Write-Host "`nCurrent git branches:" -ForegroundColor Yellow
    
    $count = 1
    foreach ($branch in $branches) {
        if ($branch -eq $currentBranch) {
            Write-Host "* $count - $branch" -ForegroundColor Green
        }
        else {
            Write-Host "  $count - $branch"
        }
        $count++
    }
    Write-Host ""
}

# gbs - Squash all commits on current branch
function gbs {
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    $mainBranch = Get-MainBranchName
    if (-not $mainBranch) { return }
    
    $currentBranch = git branch --show-current
    
    if ($currentBranch -eq $mainBranch) {
        Write-Host "Error: Cannot squash on main branch" -ForegroundColor Red
        return
    }
    
    $mergeBase = git merge-base $mainBranch $currentBranch
    $numCommits = git rev-list --count "$mergeBase..$currentBranch"
    
    if ($numCommits -eq 1) {
        Write-Host "Only 1 commit on branch, no squashing needed" -ForegroundColor Yellow
        return
    }
    
    git reset --soft "HEAD~$numCommits"
    git commit -m "chore: squashed $numCommits commits"
    git push --force
}

# gc - Commit all changes with message and push
function gc {
    param([string]$message = "chore: update")
    
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    $branchName = git branch --show-current
    $remoteBranches = git ls-remote --heads origin $branchName 2>$null
    
    if (-not $remoteBranches) {
        Write-Host "Error: Remote branch '$branchName' does not exist. Run 'git push' first." -ForegroundColor Red
        return
    }
    
    git add --all
    
    # Check if there are changes to commit
    $status = git diff --cached --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Error: No changes to commit" -ForegroundColor Yellow
        return
    }
    
    git commit -m $message
    git pull --rebase
    git push
    
    gcs
}

# gcs - Show last commit in browser
function gcs {
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    $commitSha = git rev-parse HEAD
    $remoteUrl = git config --get remote.origin.url
    
    $url = $null
    
    if ($remoteUrl -match "github\.com") {
        # Parse GitHub URL
        if ($remoteUrl -match "^git@github\.com:([^/]+)/(.+?)(\.git)?$") {
            $owner = $matches[1]
            $repo = $matches[2]
            $url = "https://github.com/$owner/$repo/commit/$commitSha"
        }
        elseif ($remoteUrl -match "https://github\.com/([^/]+)/(.+?)(\.git)?$") {
            $owner = $matches[1]
            $repo = $matches[2]
            $url = "https://github.com/$owner/$repo/commit/$commitSha"
        }
    }
    elseif ($remoteUrl -match "dev\.azure\.com|azuredevops") {
        # Parse Azure DevOps URL
        $repoName = Split-Path (git rev-parse --show-toplevel) -Leaf
        
        if ($remoteUrl -match "dev\.azure\.com/([^/]+)/([^/]+)") {
            $org = $matches[1]
            $project = $matches[2]
            $url = "https://dev.azure.com/$org/$project/_git/$repoName/commit/$commitSha"
        }
        elseif ($remoteUrl -match "azuredevops\.logixhealth\.com/([^/]+)/([^/]+)") {
            $org = $matches[1]
            $project = $matches[2]
            $url = "https://azuredevops.logixhealth.com/$org/$project/_git/$repoName/commit/$commitSha"
        }
        elseif ($remoteUrl -match "logixhealth") {
            # Fallback for LogixHealth
            $url = "https://dev.azure.com/logixhealth/Main/_git/$repoName/commit/$commitSha"
        }
    }
    
    if ($url) {
        Start-Process $url
    }
    else {
        Write-Host "Commit SHA: $commitSha" -ForegroundColor Yellow
    }
}

# gcu - Undo last commit (soft reset)
function gcu { 
    git reset HEAD~1 --soft 
}

# gpr - Create pull request
function gpr {
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    $remoteUrl = git config --get remote.origin.url
    
    if ($remoteUrl -match "github\.com") {
        if (Get-Command gh -ErrorAction SilentlyContinue) {
            gh pr create --fill-first --web
        }
        else {
            Write-Host "GitHub CLI not installed. Install from: https://cli.github.com/" -ForegroundColor Yellow
        }
    }
    else {
        # Azure DevOps
        $branchName = git branch --show-current
        $repoName = Split-Path (git rev-parse --show-toplevel) -Leaf
        
        if ($remoteUrl -match "azuredevops\.logixhealth\.com/([^/]+)/([^/]+)") {
            $org = $matches[1]
            $project = $matches[2]
            $url = "https://azuredevops.logixhealth.com/$org/$project/_git/$repoName/pullrequestcreate?sourceRef=$branchName"
        }
        else {
            $url = "https://dev.azure.com/logixhealth/Main/_git/$repoName/pullrequestcreate?sourceRef=$branchName"
        }
        
        Start-Process $url
    }
}

# grbc - Rebase continue (with auto-add)
function grbc {
    git add --all
    git rebase --continue
}

# grbm - Rebase on main
function grbm {
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    $mainBranch = Get-MainBranchName
    if (-not $mainBranch) { return }
    
    $currentBranch = git branch --show-current
    
    if ($currentBranch -eq $mainBranch) {
        Write-Host "Already on $mainBranch branch" -ForegroundColor Yellow
        return
    }
    
    git fetch origin $mainBranch
    git rebase origin/$mainBranch
    git push --force
}

# grv - Revert commit
function grv {
    param([string]$commitSha)
    
    if (-not $commitSha) {
        Write-Host "Error: Commit SHA required" -ForegroundColor Red
        return
    }
    
    git revert $commitSha
    git push
}

# grvc - Revert continue (with auto-add)
function grvc {
    git add --all
    git revert --continue
}

# grvl - Revert last commit
function grvl {
    git revert HEAD --no-edit
    git push
    gcs
}

# gsq - Squash N commits
function gsq {
    param([int]$numCommits)
    
    if (-not $numCommits) {
        Write-Host "Error: Number of commits required" -ForegroundColor Red
        return
    }
    
    git reset --soft "HEAD~$numCommits"
    git commit -m "chore: squash $numCommits commits"
    git push --force
}

# gsw - Switch by branch name or number
function gsw {
    param([string]$branchOrNumber)
    
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    if (-not $branchOrNumber) {
        Write-Host "Error: Branch name or number required" -ForegroundColor Red
        return
    }
    
    # If number, get branch name from list
    if ($branchOrNumber -match '^\d+$') {
        $branches = git branch --format="%(refname:short)" | Sort-Object
        $index = [int]$branchOrNumber - 1
        if ($index -ge 0 -and $index -lt $branches.Count) {
            $branchName = $branches[$index]
        }
        else {
            Write-Host "Error: Branch number $branchOrNumber does not exist" -ForegroundColor Red
            return
        }
    }
    else {
        $branchName = $branchOrNumber
    }
    
    git switch $branchName
}

# gswm - Switch to main (with cleanup)
function gswm {
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    $mainBranch = Get-MainBranchName
    if (-not $mainBranch) { return }
    
    # Stash if needed
    $status = git status --porcelain
    if ($status) {
        Write-Host "Stashing changes..." -ForegroundColor Yellow
        git stash push -m "Auto-stash before switching to $mainBranch"
    }
    
    git switch $mainBranch
    git pull --rebase
    gbc -SkipFetch
    git stash list
}

# gtc - Clean local tags not on remote
function gtc {
    if (-not (Get-IsGitRepo)) {
        Write-Host "Error: Not inside a Git repository" -ForegroundColor Red
        return
    }
    
    git tag -l | ForEach-Object { git tag -d $_ }
    git fetch --tags
    
    Write-Host "`nCurrent git tags:" -ForegroundColor Yellow
    git tag
}

# Terraform shortcuts
function ti { terraform init }
function ta { terraform apply }
function taa { terraform apply -auto-approve }
function td { terraform destroy }
function tda { terraform destroy -auto-approve }
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
    
    if ($env:USERDOMAIN) {
        Write-Host "Domain       : $env:USERDOMAIN" -ForegroundColor Green
    }
    
    Write-Host "PowerShell   : $($PSVersionTable.PSVersion)" -ForegroundColor Green
    
    if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        if ($os) {
            Write-Host "OS           : $($os.Caption)" -ForegroundColor Green
            $uptime = (Get-Date) - $os.LastBootUpTime
            Write-Host "Uptime       : $uptime" -ForegroundColor Green
        }
    }
    else {
        Write-Host "OS           : $(uname -s)" -ForegroundColor Green
    }
    
    Write-Host "═══════════════════════════════════════`n" -ForegroundColor Cyan
}

# Enhanced help function
function help-me {
    Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║       PowerShell Commands Help        ║" -ForegroundColor Magenta
    Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Magenta
    
    Write-Host "`n📁 Navigation:" -ForegroundColor Yellow
    Write-Host "  r          → Go to repositories folder" -ForegroundColor Gray
    Write-Host "  desktop    → Go to Desktop" -ForegroundColor Gray
    Write-Host "  downloads  → Go to Downloads" -ForegroundColor Gray
    Write-Host "  docs       → Go to Documents" -ForegroundColor Gray
    Write-Host "  ..         → Go up one directory" -ForegroundColor Gray
    Write-Host "  ...        → Go up two directories" -ForegroundColor Gray
    
    Write-Host "`n🔧 Git Commands (Basic):" -ForegroundColor Yellow
    Write-Host "  gs         → git status (porcelain)" -ForegroundColor Gray
    Write-Host "  ga         → git add" -ForegroundColor Gray
    Write-Host "  gaa        → git add --all" -ForegroundColor Gray
    Write-Host "  gc 'msg'   → git commit all + push" -ForegroundColor Gray
    Write-Host "  gp         → git pull --rebase" -ForegroundColor Gray
    Write-Host "  gu         → git push" -ForegroundColor Gray
    Write-Host "  guf        → git push --force" -ForegroundColor Gray
    Write-Host "  gd         → git diff" -ForegroundColor Gray
    Write-Host "  gl         → git log" -ForegroundColor Gray
    Write-Host "  glg        → git log graph (pretty)" -ForegroundColor Gray
    
    Write-Host "`n🔀 Git Branches:" -ForegroundColor Yellow
    Write-Host "  gb desc    → create branch (auto-named)" -ForegroundColor Gray
    Write-Host "  gbl        → list branches with numbers" -ForegroundColor Gray
    Write-Host "  gsw 2      → switch to branch #2" -ForegroundColor Gray
    Write-Host "  gswm       → switch to main + cleanup" -ForegroundColor Gray
    Write-Host "  gbd 2      → delete branch #2 (local+remote)" -ForegroundColor Gray
    Write-Host "  gbdl 2     → delete branch #2 (local only)" -ForegroundColor Gray
    Write-Host "  gbc        → clean merged branches" -ForegroundColor Gray
    Write-Host "  gbs        → squash all branch commits" -ForegroundColor Gray
    
    Write-Host "`n📝 Git Advanced:" -ForegroundColor Yellow
    Write-Host "  gpr        → create pull request" -ForegroundColor Gray
    Write-Host "  gcs        → show last commit in browser" -ForegroundColor Gray
    Write-Host "  gcu        → undo last commit (soft)" -ForegroundColor Gray
    Write-Host "  grb        → git rebase" -ForegroundColor Gray
    Write-Host "  grbm       → rebase on main" -ForegroundColor Gray
    Write-Host "  grbc       → rebase continue" -ForegroundColor Gray
    Write-Host "  gsq 3      → squash last 3 commits" -ForegroundColor Gray
    Write-Host "  gst/gstp   → stash/stash pop" -ForegroundColor Gray
    Write-Host "  grv sha    → revert commit" -ForegroundColor Gray
    Write-Host "  grvl       → revert last commit" -ForegroundColor Gray
    
    Write-Host "`n☁️ Infrastructure:" -ForegroundColor Yellow
    Write-Host "  ti         → terraform init" -ForegroundColor Gray
    Write-Host "  ta         → terraform apply" -ForegroundColor Gray
    Write-Host "  taa        → terraform apply -auto-approve" -ForegroundColor Gray
    Write-Host "  td         → terraform destroy" -ForegroundColor Gray
    Write-Host "  tda        → terraform destroy -auto-approve" -ForegroundColor Gray
    Write-Host "  tf         → terraform fmt" -ForegroundColor Gray
    Write-Host "  tv         → terraform validate" -ForegroundColor Gray
    Write-Host "  tc         → terraform clean (remove files)" -ForegroundColor Gray
    
    Write-Host "`n🛠️ Utilities:" -ForegroundColor Yellow
    Write-Host "  ll         → List files (Get-ChildItem)" -ForegroundColor Gray
    Write-Host "  la         → List all files (including hidden)" -ForegroundColor Gray
    Write-Host "  which cmd  → Find command location" -ForegroundColor Gray
    Write-Host "  grep       → Search in files" -ForegroundColor Gray
    Write-Host "  touch file → Create empty file" -ForegroundColor Gray
    Write-Host "  mkcd dir   → Create and enter directory" -ForegroundColor Gray
    Write-Host "  find-file  → Search for files by name" -ForegroundColor Gray
    Write-Host "  find-text  → Search for text in files" -ForegroundColor Gray
    Write-Host "  calc expr  → Quick calculator" -ForegroundColor Gray
    Write-Host "  sysinfo    → Show system information" -ForegroundColor Gray
    Write-Host "  reload     → Reload PowerShell profile" -ForegroundColor Gray
    
    Write-Host "`n💡 Tips:" -ForegroundColor Yellow
    Write-Host "  - Tab completion works everywhere!" -ForegroundColor DarkGray
    Write-Host "  - Use Ctrl+R to search command history" -ForegroundColor DarkGray
    Write-Host "  - Type 'Get-Command g*' to see all git functions" -ForegroundColor DarkGray
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
    Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | Select-String -Pattern $pattern
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
    Set-PSReadLineKeyHandler -Key Tab -Function Complete
}

# Common PSReadLine settings (both PS5 & PS7)
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Load additional functions if they exist
$functionsPath = Join-Path (Split-Path $PROFILE) "functions.ps1"
if (Test-Path $functionsPath) { . $functionsPath }

# Load work-specific settings if on work machine
if ($env:USERDOMAIN -match "LogixHealth|LOGIX") {
    $workPath = Join-Path (Split-Path $PROFILE) "work-specific.ps1"
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