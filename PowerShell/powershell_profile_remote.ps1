# PowerShell Remote Profile
# ----------------
# Helper Functions
# ----------------

function Add-LogixCertToRequestsBundle {
    if (-not $env:REQUESTS_CA_BUNDLE) { return }
    
    if (-not (Test-Path $env:REQUESTS_CA_BUNDLE) -or (Get-Item $env:REQUESTS_CA_BUNDLE).Length -eq 0) {
        Write-Error "The REQUESTS_CA_BUNDLE environment variable is set to '$env:REQUESTS_CA_BUNDLE', but this file does not exist or is 0 bytes."
        return
    }
    
    $certificateName = "BEDROOTCA001"
    $content = Get-Content $env:REQUESTS_CA_BUNDLE -Raw
    
    if ($content -notmatch $certificateName) {
        Write-Error "The REQUESTS_CA_BUNDLE file does not have the '$certificateName' certificate in it."
        Write-Host "`nRun this command to fix it:"
        Write-Host "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Zamiell/configs/refs/heads/main/certs/$certificateName.crt' | Select-Object -ExpandProperty Content | Add-Content -Path `$env:REQUESTS_CA_BUNDLE"
        return
    }
}

function Add-PathDirectory {
    param([string]$Directory)
    
    if (-not $Directory) {
        Write-Error "The path is required. Usage: Add-PathDirectory <path>"
        return
    }
    
    if ((Test-Path $Directory) -and ($env:Path -notlike "*$Directory*")) {
        $env:Path = "$env:Path;$Directory"
    }
}

function Assert-FeatureBranch {
    $branchName = git branch --show-current 2>$null
    $mainBranch = Get-MainBranchName
    
    if ($branchName -eq $mainBranch) {
        Write-Error "This command is intended to be run on a feature branch and you are currently on the '$mainBranch' branch."
        throw
    }
}

function Assert-GitRepository {
    git rev-parse --is-inside-work-tree 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Not inside a Git repository."
        throw
    }
}

function Assert-MainBranch {
    $branchName = git branch --show-current 2>$null
    $mainBranch = Get-MainBranchName
    
    if ($branchName -ne $mainBranch) {
        Write-Error "This command is intended to be run on the '$mainBranch' branch and you are currently on the '$branchName' branch."
        throw
    }
}

function Get-BranchNameFromNumber {
    param([string]$BranchNameOrNumber)
    
    if (-not $BranchNameOrNumber) {
        Write-Error "The branch name or number is required."
        return
    }
    
    if ($BranchNameOrNumber -match '^\d+$') {
        $branches = git branch --format="%(refname:short)" | Sort-Object
        $branchArray = @($branches)
        $index = [int]$BranchNameOrNumber - 1
        
        if ($index -lt 0 -or $index -ge $branchArray.Count) {
            Write-Error "Branch number $BranchNameOrNumber does not exist."
            return
        }
        
        return $branchArray[$index]
    }
    
    return $BranchNameOrNumber
}

function Get-MainBranchName {
    if (git show-ref --verify --quiet refs/heads/main 2>$null) {
        return "main"
    } elseif (git show-ref --verify --quiet refs/heads/master 2>$null) {
        return "master"
    } else {
        Write-Error "There was not a 'main' branch or 'master' branch in this repository."
        throw
    }
}

function Get-MergeBase {
    $branchName = git branch --show-current 2>$null
    $mainBranch = Get-MainBranchName
    
    $mergeBase = git merge-base $mainBranch $branchName 2>$null
    if (-not $mergeBase) {
        Write-Error "Could not find a common ancestor with the '$mainBranch' branch."
        throw
    }
    
    return $mergeBase
}

function Test-GitBash {
    return $false  # PowerShell is not Git Bash
}

function Test-GitHubRepository {
    git rev-parse --is-inside-work-tree 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        return $false
    }
    
    $remoteUrl = git remote get-url origin 2>$null
    return ($remoteUrl -match "github\.com")
}

function Show-FilesAndBranches {
    Get-ChildItem -Force
    
    $currentDir = Get-Location
    $gitRoot = git rev-parse --show-toplevel 2>$null
    
    if ($currentDir.Path -eq $gitRoot) {
        Write-Host ""
        Show-GitBranches
    }
}

# ---------------------
# Environment Variables
# ---------------------

# Load secret environment variables from .env file
if (Test-Path "$HOME\.env") {
    Get-Content "$HOME\.env" | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $key = $matches[1]
            $value = $matches[2]
            [Environment]::SetEnvironmentVariable($key, $value, 'Process')
        }
    }
}

# Fix self-signed certs for LogixHealth
$certPaths = @(
    "C:\tls\BEDROOTCA001.crt",
    "C:\_IT\tls\BEDROOTCA001.crt"
)

foreach ($certPath in $certPaths) {
    if (Test-Path $certPath) {
        $env:COMPANY_CERT_PATH = $certPath
        $env:NODE_EXTRA_CA_CERTS = $certPath
        $env:CURL_CA_BUNDLE = $certPath
        break
    }
}

# Set REQUESTS_CA_BUNDLE for Azure CLI
$azCliPaths = @(
    "C:\Program Files\Microsoft SDKs\Azure\CLI2\lib\site-packages\certifi\cacert.pem",
    "C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\lib\site-packages\certifi\cacert.pem"
)

foreach ($path in $azCliPaths) {
    if (Test-Path $path) {
        $env:REQUESTS_CA_BUNDLE = $path
        break
    }
}

Add-LogixCertToRequestsBundle

# Get username
$env:OS_USERNAME = if ($env:USERNAME) { $env:USERNAME } else { $env:USER }

# ----
# Path
# ----

# Add browsers to path
Add-PathDirectory "C:\Program Files\Google\Chrome\Application"
Add-PathDirectory "C:\Program Files (x86)\Microsoft\Edge\Application"

# Add common development tools
Add-PathDirectory "$HOME\.bun\bin"
Add-PathDirectory "$HOME\.local\bin"

# ----------------------
# Miscellaneous Commands
# ----------------------

# Ask an LLM a question
function ai {
    param([Parameter(ValueFromRemainingArguments)]$Prompt)
    
    if (-not $Prompt) {
        Write-Error "The prompt is required. Usage: ai <prompt>"
        return
    }
    
    Write-Host "AI command not yet implemented in PowerShell profile"
}

# Change directory and show contents
function cd {
    param([string]$Path = "~")
    
    Set-Location $Path
    Show-FilesAndBranches
}

# Change directory to git root
function cdg {
    Assert-GitRepository
    
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if (-not $gitRoot) {
        Write-Error "Failed to get the root of the current git repository."
        return
    }
    
    Set-Location $gitRoot
}

# Better ls alias
Set-Alias -Name ll -Value Get-ChildItem

# Open URL in browser
function o {
    param([string]$Url)
    
    if (-not $Url) {
        Write-Error "URL is required. Usage: o <url>"
        return
    }
    
    if ($Url -match "logixhealth" -and (Get-Command msedge -ErrorAction SilentlyContinue)) {
        Start-Process msedge $Url
    } elseif (Get-Command chrome -ErrorAction SilentlyContinue) {
        Start-Process chrome $Url
    } else {
        Start-Process $Url
    }
}

# Switch to repositories directory
$repositoriesDirs = @(
    "C:\Users\$env:OS_USERNAME\Repositories",
    "D:\Repositories",
    "C:\Repositories"
)

foreach ($dir in $repositoriesDirs) {
    if (Test-Path $dir) {
        $env:REPOSITORIES_DIR = $dir
        function r { Set-Location $env:REPOSITORIES_DIR }
        
        # Start in repositories directory if in home
        if ((Get-Location).Path -eq $HOME) {
            Set-Location $env:REPOSITORIES_DIR
        }
        break
    }
}

# ----------------
# kubectl Commands
# ----------------

Set-Alias -Name k -Value kubectl
function kdd { kubectl describe deployment @args }
function kdp { kubectl describe pod @args }
function kds { kubectl describe service @args }
function kgd { kubectl get deployment @args }
function kgp { kubectl get pod @args }

# ------------
# npm Commands
# ------------

function Get-PackageManager {
    $currentDir = Get-Location
    
    while ($currentDir) {
        if (Test-Path "$currentDir\package-lock.json") { return "npm" }
        if (Test-Path "$currentDir\yarn.lock") { return "yarn" }
        if (Test-Path "$currentDir\pnpm-lock.yaml") { return "pnpm" }
        if (Test-Path "$currentDir\bun.lock") { return "bun" }
        
        $parent = Split-Path $currentDir -Parent
        if ($parent -eq $currentDir) { break }
        $currentDir = $parent
    }
    
    return "npm"
}

function Invoke-PackageScript {
    param([string]$Script)
    
    if (-not $Script) {
        Write-Error "The script name is required."
        return
    }
    
    $pm = Get-PackageManager
    & $pm run $Script
}

function b { Invoke-PackageScript "build" }
function d { Invoke-PackageScript "dev" }
function l { Invoke-PackageScript "lint" }
function la { Invoke-PackageScript "lint-all" }
function p { Invoke-PackageScript "publish" }
function s { Invoke-PackageScript "start" }
function t { Invoke-PackageScript "test" }
function u { Invoke-PackageScript "update" }

# ----------
# Git Config
# ----------

git config --global core.autocrlf false
git config --global core.ignorecase false
git config --global diff.colorMoved zebra
git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global pull.rebase true
git config --global push.autoSetupRemote true

# ------------
# Git Commands
# ------------

# Git add
function ga { git add @args }
function gaa { git add --all }

# Git branch
function gb {
    param(
        [string]$BranchName = "misc",
        [string]$ApplicationName = "misc",
        [switch]$NoConvention
    )
    
    Assert-GitRepository
    
    $newBranchName = $BranchName
    if (-not $NoConvention -and -not (Test-GitHubRepository)) {
        $newBranchName = "feature/$ApplicationName/$env:OS_USERNAME/$BranchName"
    }
    
    if ((git status --porcelain)) {
        Write-Host "The repository is not clean. Stashing all of your existing changes."
        git stash push --message "Auto-stash before creating a new git branch"
    }
    
    $mainBranch = Get-MainBranchName
    
    if ((git branch --show-current) -ne $mainBranch) {
        git switch $mainBranch
    }
    
    git pull --rebase
    git switch --create $newBranchName
    git push
    
    if ((git stash list | Measure-Object).Count -gt 0) {
        Write-Host "A previous git stash exists. Applying it to this new branch."
        git stash pop
    }
    
    Write-Host ""
    Show-GitBranches
}

function gb_ { gb -NoConvention @args }

# Git branch clean
function gbc {
    param([switch]$SkipFetch)
    
    Assert-GitRepository
    
    $mainBranch = Get-MainBranchName
    
    if ((git branch --show-current) -ne $mainBranch) {
        git switch $mainBranch
    }
    
    if (-not $SkipFetch) {
        git fetch --prune --quiet
    }
    
    # Delete branches that are gone from remote
    git branch -vv | Select-String ": gone]" | ForEach-Object {
        $branchName = $_ -replace '\s+.*', ''
        git branch --delete --force $branchName
    }
    
    Write-Host ""
    Show-GitBranches
}

# Git branch delete
function gbd {
    param(
        [string]$BranchNameOrNumber,
        [switch]$OnlyLocal
    )
    
    if (-not $BranchNameOrNumber) {
        Write-Error "Branch name or number is required. Usage: gbd <branch-name-or-number> [-OnlyLocal]"
        return
    }
    
    Assert-GitRepository
    
    $branchName = Get-BranchNameFromNumber $BranchNameOrNumber
    
    if ($branchName -in @("main", "master")) {
        Write-Error "You cannot use this command to delete the '$branchName' branch."
        return
    }
    
    $currentBranch = git branch --show-current
    if ($branchName -eq $currentBranch) {
        Write-Error "You are deleting branch '$branchName', but that is the branch that you are currently on."
        return
    }
    
    # Delete locally
    if (git show-ref --verify --quiet "refs/heads/$branchName" 2>$null) {
        git branch --delete --force $branchName
        Write-Host "Deleted branch '$branchName' locally."
    } else {
        Write-Warning "Branch '$branchName' does not exist locally."
    }
    
    # Delete remotely
    if (-not $OnlyLocal) {
        git push origin ":$branchName" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Deleted branch '$branchName' remotely."
        } else {
            Write-Warning "Branch '$branchName' does not exist on remote origin."
        }
    }
    
    Write-Host ""
    Show-GitBranches
}

function gbdl { gbd $args[0] -OnlyLocal }

# Git branch list
function gbl {
    Show-GitBranches
}

function Show-GitBranches {
    Assert-GitRepository
    
    $branches = git branch --format="%(refname:short)" | Sort-Object
    $currentBranch = git branch --show-current
    
    Write-Host "Current git branches:"
    
    $count = 1
    foreach ($branch in $branches) {
        if ($branch -eq $currentBranch) {
            Write-Host -ForegroundColor Green "* $count - $branch"
        } else {
            Write-Host "  $count - $branch"
        }
        $count++
    }
}

# Git commit
function gc {
    param(
        [Parameter(ValueFromRemainingArguments)]$CommitMessage,
        [switch]$Amend
    )
    
    Assert-GitRepository
    
    if (-not (git config user.name)) {
        Write-Error "Git user name not set. Run: git config --global user.name 'Your Name'"
        return
    }
    
    if (-not (git config user.email)) {
        Write-Error "Git user email not set. Run: git config --global user.email you@example.com"
        return
    }
    
    git add --all
    
    if (-not $Amend -and -not (git diff --cached --quiet)) {
        Write-Error "There are no changes to commit."
        return
    }
    
    if ($Amend) {
        git commit --amend --no-edit
        git push --force-with-lease
    } else {
        $message = if ($CommitMessage) { $CommitMessage -join " " } else { "chore: update something" }
        git commit --message $message
        git pull --rebase
        git push
    }
    
    Show-LastCommit
}

function gca { gc -Amend }

# Git commit show
function gcs {
    Assert-GitRepository
    
    $commitSha = git rev-parse HEAD
    $remoteUrl = git remote get-url origin
    
    if ($remoteUrl -match "github\.com") {
        if ($remoteUrl -match "github\.com[:/]([^/]+)/([^/\.]+)") {
            $author = $matches[1]
            $repo = $matches[2]
            $url = "https://github.com/$author/$repo/commit/$commitSha"
            o $url
        }
    } elseif ($remoteUrl -match "azuredevops\.logixhealth\.com") {
        # Parse Azure DevOps URL
        Write-Host "Azure DevOps commit URL parsing not yet implemented"
    }
}

function Show-LastCommit {
    $commitSha = git rev-parse HEAD
    Write-Host "Last commit: $commitSha"
}

# Git commit undo
function gcu {
    param([int]$NumCommits = 1)
    
    Assert-GitRepository
    git reset "HEAD~$NumCommits" --soft
}

# Git diff
function gd { git diff @args }

# Git log
function gl { git log @args }
function glg { 
    git log --graph --pretty=format:'%C(yellow)%h%Creset %C(cyan)%d%Creset %C(white)%s%Creset %C(green)(%an)%Creset%n%w(0,8,8)%b%Creset' --all --decorate 
}

# Git merge conflicts
function gmc { git diff --name-only --diff-filter=U }
function gmco { git diff --name-only --diff-filter=U | ForEach-Object { code $_ } }

# Git pull
function gp { git pull --rebase }

# Git rebase
function grb { git rebase @args }
function grba { git rebase --abort }
function grbc { git add --all; git rebase --continue }
function grbm {
    Assert-GitRepository
    Assert-FeatureBranch
    
    $mainBranch = Get-MainBranchName
    git fetch origin $mainBranch
    git rebase "origin/$mainBranch"
    git push --force-with-lease
}

# Git reset
function grs { git reset @args }
function grsh { git reset --hard @args }
function grshm {
    Assert-GitRepository
    Assert-FeatureBranch
    
    $mainBranch = Get-MainBranchName
    git reset --hard "origin/$mainBranch"
    git push --force-with-lease
}

# Git restore
function grt {
    param([Parameter(ValueFromRemainingArguments)]$Files)
    
    Assert-GitRepository
    Assert-FeatureBranch
    
    if (-not $Files) {
        Write-Error "One or more file paths are required."
        return
    }
    
    $mergeBase = Get-MergeBase
    git checkout $mergeBase -- $Files
}

# Git revert
function grv {
    param([string]$CommitSha)
    
    if (-not $CommitSha) {
        Write-Error "Commit SHA1 is required."
        return
    }
    
    Assert-GitRepository
    git revert $CommitSha
    git push
}

function grva { git revert --abort }
function grvc { git add --all; git revert --continue }
function grvl {
    Assert-GitRepository
    git revert HEAD --no-edit
    git push
    Show-LastCommit
}

# Git status
function gs { git status --porcelain }

# Git squash
function gsq {
    param(
        [int]$NumCommits,
        [string]$CommitMessage
    )
    
    if (-not $NumCommits) {
        Write-Error "You must provide the number of commits to squash."
        return
    }
    
    Assert-GitRepository
    
    if (-not $CommitMessage) {
        $CommitMessage = "chore: squash $NumCommits commits"
    }
    
    git reset --soft "HEAD~$NumCommits"
    git commit --message $CommitMessage
    git push --force-with-lease
}

# Git stash
function gst { git stash @args }
function gstd { git stash drop }
function gstl { git stash list }
function gstp { git stash pop }

# Git switch
function gsw {
    param([string]$BranchNameOrNumber)
    
    if (-not $BranchNameOrNumber) {
        Write-Error "Branch name or number is required."
        return
    }
    
    Assert-GitRepository
    
    $branchName = Get-BranchNameFromNumber $BranchNameOrNumber
    git switch $branchName
}

function gswc { git switch -c @args }
function gswm {
    Assert-GitRepository
    
    $mainBranch = Get-MainBranchName
    
    if ((git status --porcelain)) {
        Write-Host "The repository is not clean. Stashing all of your existing changes."
        git stash push --message "Auto-stash before switching to $mainBranch"
    }
    
    if ((git branch --show-current) -ne $mainBranch) {
        git switch $mainBranch
    }
    
    git pull --rebase
    gbc -SkipFetch
    git stash list
}

# Git tags clean
function gtc {
    Assert-GitRepository
    
    git tag -l | ForEach-Object { git tag -d $_ }
    git fetch --tags
    
    Write-Host ""
    Write-Host "Current git tags:"
    git tag
}

# Git push
function gu { git push @args }
function guf { git push --force-with-lease }

# ---------------
# Pulumi Commands
# ---------------

function pd { pulumi destroy @args }
function pp { pulumi preview @args }
function pu { pulumi up @args }
function puy { pulumi up --yes }

# ------------------
# Terraform Commands
# ------------------

function ta { terraform apply @args }
function taa { terraform apply -auto-approve }
function tc { Remove-Item -Recurse -Force .terraform, .terraform.lock.hcl, terraform.tfstate, terraform.tfstate.backup -ErrorAction SilentlyContinue }
function td { terraform destroy @args }
function tda { terraform destroy -auto-approve }
function tf { terraform fmt @args }
function ti { terraform init @args }
function tp { terraform plan @args }
function tv { terraform validate @args }

# ------
# Prompt
# ------

# PowerShell prompt is set via prompt function
function prompt {
    $location = Get-Location
    $gitBranch = git branch --show-current 2>$null
    
    Write-Host ""
    Write-Host -NoNewline -ForegroundColor Green "$env:USERNAME@$env:COMPUTERNAME "
    Write-Host -NoNewline -ForegroundColor Yellow "$location"
    
    if ($gitBranch) {
        Write-Host -NoNewline -ForegroundColor Cyan " ($gitBranch)"
    }
    
    Write-Host ""
    return "$ "
}

Write-Host "PowerShell profile loaded from remote configuration" -ForegroundColor Green