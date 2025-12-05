# PowerShell Profile Configuration

## Setup Instructions

### 1. Find Your PowerShell Profile Location

Run this command in PowerShell to find your profile location:

```powershell
$PROFILE
```

This will typically return something like:
- Windows PowerShell: `C:\Users\<username>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- PowerShell 7+: `C:\Users\<username>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

### 2. Create the Profile

If the profile doesn't exist, create it:

```powershell
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}
```

### 3. Add the Bootstrap Code

Edit your profile and add this code:

```powershell
# PowerShell Profile - Loads commands from GitHub repository
$configDir = "$HOME\.config"
$remoteProfilePath = "$configDir\.powershell_profile_remote.ps1"

# Create config directory if it doesn't exist
if (!(Test-Path -Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# Download the remote profile
Remove-Item -Path $remoteProfilePath -Force -ErrorAction SilentlyContinue
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Jeenil/local-configs/main/PowerShell/profile_remote.ps1" `
        -OutFile $remoteProfilePath `
        -UseBasicParsing `
        -ErrorAction Stop
    
    # Source the remote profile
    . $remoteProfilePath
} catch {
    Write-Warning "Failed to download remote PowerShell profile: $_"
    Write-Warning "Falling back to local configuration..."
}
```

### 4. Upload profile_remote.ps1 to Your GitHub Repository

1. Upload the `profile_remote.ps1` file to: `https://github.com/Jeenil/local-configs/tree/main/PowerShell/`
2. Make sure it's named exactly `profile_remote.ps1`
3. Restart PowerShell

## Command Reference

All commands from the Bash profile have been ported to PowerShell:

### Directory Navigation
- `cd <path>` - Change directory and show contents
- `cdg` - Change to git repository root
- `r` - Switch to repositories directory
- `ll` - List files (alias for Get-ChildItem)

### Git Commands

#### Branch Management
- `gb [name] [app]` - Create new git branch (with LogixHealth convention)
- `gb_ [name]` - Create new git branch (without convention)
- `gbl` - List git branches
- `gblr` - List remote git branches
- `gbc` - Clean local branches that don't exist on remote
- `gbd <branch>` - Delete branch locally and remotely
- `gbdl <branch>` - Delete branch locally only
- `gbr <app> [desc]` - Rename current branch
- `gbr_ <name>` - Rename branch without convention
- `gbs` - Squash all commits on branch
- `gsw <branch>` - Switch to branch (by name or number)
- `gswc <branch>` - Create and switch to new branch
- `gswm` - Switch to main/master branch

#### Commits
- `gc [message]` - Commit all changes with message
- `gca` - Amend last commit
- `gcam` - Amend last commit and edit message
- `gcs` - Show last commit in browser
- `gcu [n]` - Undo last N commits (default 1)

#### Status & Diff
- `gs` - Git status (porcelain format)
- `gd` - Git diff
- `gl` - Git log
- `glg` - Git log with graph

#### Staging
- `ga <files>` - Git add specific files
- `gaa` - Git add all

#### Push/Pull
- `gp` - Git pull with rebase
- `gu` - Git push
- `guf` - Git push force with lease

#### Rebase
- `grb` - Git rebase
- `grba` - Git rebase abort
- `grbc` - Git rebase continue (adds all first)
- `grbm` - Rebase on origin/main

#### Reset
- `grs` - Git reset
- `grsh` - Git reset hard
- `grshm` - Reset hard to origin/main

#### Revert
- `grv <sha>` - Revert a commit
- `grva` - Revert abort
- `grvc` - Revert continue
- `grvl` - Revert last commit

#### Stash
- `gst` - Git stash
- `gstd` - Git stash drop
- `gstl` - Git stash list
- `gstp` - Git stash pop

#### Tags
- `gtc` - Clean local tags

#### Merge Conflicts
- `gmc` - List files with merge conflicts
- `gmco` - Open files with merge conflicts in VS Code

#### Squash
- `gsq <n> [message]` - Squash last N commits

#### Restore
- `grt <files>` - Restore files from merge base

### kubectl Commands
- `k` - kubectl alias
- `kdd` - kubectl describe deployment
- `kdp` - kubectl describe pod
- `kds` - kubectl describe service
- `kgd` - kubectl get deployment
- `kgp` - kubectl get pod

### npm/Package Manager Commands
- `b` - Build (runs npm/yarn/pnpm/bun run build)
- `d` - Dev (runs dev script)
- `l` - Lint (runs lint script)
- `la` - Lint all (runs lint-all script)
- `p` - Publish (runs publish script)
- `s` - Start (runs start script)
- `t` - Test (runs test script)
- `u` - Update (runs update script)

### Pulumi Commands
- `pd` - pulumi destroy
- `pp` - pulumi preview
- `pu` - pulumi up
- `puy` - pulumi up --yes

### Terraform Commands
- `ta` - terraform apply
- `taa` - terraform apply -auto-approve
- `tc` - terraform clean (removes .terraform, lock files, state files)
- `td` - terraform destroy
- `tda` - terraform destroy -auto-approve
- `tf` - terraform fmt
- `ti` - terraform init
- `tp` - terraform plan
- `tv` - terraform validate

### Utility Commands
- `o <url>` - Open URL in browser

## Features

### Auto Git Configuration
The profile automatically sets these git configs:
- `core.autocrlf` = false
- `core.ignorecase` = false
- `diff.colorMoved` = zebra
- `fetch.prune` = true
- `fetch.pruneTags` = true
- `pull.rebase` = true
- `push.autoSetupRemote` = true

### Environment Variables
- Automatically loads `.env` file from home directory
- Sets up LogixHealth certificate paths if found
- Configures Azure CLI certificate bundle

### Custom Prompt
Shows:
- Username@Hostname
- Current directory
- Git branch (if in a git repository)

## Differences from Bash Version

Some features from the Bash version are not yet implemented:
1. LLM-powered commit messages (requires API integration)
2. Azure DevOps pull request creation
3. Some GitHub-specific features (use `gh` CLI instead)

## Troubleshooting

### Execution Policy Error

If you get an error about execution policy, run PowerShell as Administrator and execute:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Profile Not Loading

1. Check that the profile exists: `Test-Path $PROFILE`
2. Check for errors: `powershell -NoProfile -File $PROFILE`
3. Reload profile: `. $PROFILE`

### Remote Download Fails

If the remote download fails, the profile will warn you but continue. Check:
1. Internet connectivity
2. GitHub repository URL is correct
3. File `profile_remote.ps1` exists in your repository

## File Structure

```
Jeenil/local-configs/
└── PowerShell/
    ├── Microsoft.PowerShell_profile.ps1  # Bootstrap (place in your $PROFILE location)
    └── profile_remote.ps1                 # Remote commands (upload to GitHub)
```

## Environment-Specific Configuration

Create a `~/.env` file to store environment-specific variables:

```powershell
GEMINI_API_KEY=your-key-here
AZDO_PERSONAL_ACCESS_TOKEN=your-token-here
```

The profile will automatically load these on startup.

## Updates

To update your profile:
1. Modify `profile_remote.ps1` in your GitHub repository
2. Restart PowerShell (it downloads fresh each time)

Alternatively, reload without restarting:
```powershell
. $PROFILE
```

## Contributing

This configuration mirrors the Bash profile from [Zamiell/configs](https://github.com/Zamiell/configs). 

## License

Same as the parent Bash configuration.