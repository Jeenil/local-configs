# Bash Command Reference

This is an auto-generated reference of every alias and helper function loaded by `.bash_profile` — most come from [Jeenil/configs](https://github.com/Jeenil/configs)'s `bash/commands/` directory, plus a few personal additions in `bashrc_local.sh` here.

Regenerate this file after configs change by running `./generate-readme.sh`.

## Table of Contents

- [Aks](#aks) (aks.sh) — 13 commands
- [Browsers](#browsers) (browsers.sh) — 2 commands
- [Change Directory](#change-directory) (change-directory.sh) — 5 commands
- [Git](#git) (git.sh) — 74 commands
- [Github](#github) (github.sh) — 3 commands
- [Kubectl](#kubectl) (kubectl.sh) — 6 commands
- [Miscellaneous](#miscellaneous) (miscellaneous.sh) — 40 commands
- [Npm](#npm) (npm.sh) — 11 commands
- [Pulumi](#pulumi) (pulumi.sh) — 9 commands
- [Say](#say) (say.sh) — 1 command
- [Ssh](#ssh) (ssh.sh) — 2 commands
- [Terraform](#terraform) (terraform.sh) — 18 commands
- [Personal Overrides (this repo)](#personal-overrides-this-repo) (bashrc_local.sh) — 1 command

## Aks

_Source: `aks.sh`_

### `aks`

_(undocumented)_

### `akspim`

"akspim" activates or deactivates AKS PIM role assignments for shared clusters.

### `akspim-info`

_(undocumented)_

### `akspim-success`

_(undocumented)_

### `akspim-warning`

_(undocumented)_

### `akspim-error`

_(undocumented)_

### `akspim-usage`

_(undocumented)_

### `akspim-generate-guid`

_(undocumented)_

### `akspim-resolve-environment`

_(undocumented)_

### `akspim-select-environment`

_(undocumented)_

### `akspim-wait-for-readiness`

_(undocumented)_

### `akspim-submit-activation-request`

_(undocumented)_

### `akspim-submit-deactivation-request`

_(undocumented)_

## Browsers

_Source: `browsers.sh`_

### `chrome`

Shortcut for `google-chrome`.

```sh
alias chrome="google-chrome"
```

### `msedge`

Shortcut for `microsoft-edge`.

```sh
alias msedge="microsoft-edge"
```

## Change Directory

_Source: `change-directory.sh`_

### `cd`

We have to use braces instead of parenthesis here.

### `cdg`

"cdg" stands for "change directory git", which will change the working directory to the root of
the current git repository. If used in a directory that is not part of a Git repository, it will
throw an error.

### `cdr`

"cdr" is short for "change directory repositories".

```sh
alias cdr="builtin cd $REPOSITORIES_DIR"
```

### `cdr2`

Shortcut for `builtin cd /mnt/d/Repositories`.

```sh
alias cdr2="builtin cd /mnt/d/Repositories"
```

### `cdn`

Shortcut for `builtin cd /mnt/c/Repositories/notes`.

```sh
alias cdn="builtin cd /mnt/c/Repositories/notes"
```

## Git

_Source: `git.sh`_

### `ga`

"ga" is short for "git add".

```sh
alias ga="git add"
```

### `gaa`

"gaa" is short for "git add --all".

```sh
alias gaa="git add --all"
```

### `gb`

- "gb" is short for creating a new git branch, which is a common coding task.
- If the remote repository is not GitHub, this will make the branch according to a special branch
  naming convention.
- Doing a push is important after creating a new branch because it prevents subsequent "git pull"
  calls from failing.
- You can use the "-n" or "--no-convention" flag to omit the naming convention.

### `gb_`

"gb\_" is an alias for "gb --no-convention".

```sh
alias gb_="gb --no-convention"
```

### `gbcl`

"gbcl" is short for "git branch clean", which will remove all local branches that do not exist on
the remote repository.
<https://stackoverflow.com/questions/7726949/remove-tracking-branches-no-longer-on-remote>

### `gbcp`

"gbcp" is short for "git branch copy", which will put the branch name into the clipboard.

### `gbd`

"gbd" is short for "git branch delete", which will delete the branch both locally and remotely.
Use "current" to run "gswm" before deleting the current branch.

### `gbdl`

"gbdl" is short for "git branch delete local", which will delete the branch locally (and not
remotely).

### `gbe`

"gbe" is short for "git branch exists", which will check if the current branch exists on the
remote repository.

### `gbl`

"gbl" is short for "git branch list". ("gb" is already taken by another command.)

### `gblr`

"gblr" is short for "git branch list remote".

### `gbo`

"gbo" is short for "git branch open", which will open all of the changed files in this branch
inside Visual Studio Code. This command will throw an error if there are 10 or more files
changed as part of the branch.

### `gbr`

"gbr" is short for "git branch rename".

- You can use the "-n" or "--no-convention" flag to omit the special naming convention.

### `gbr_`

"gbr\_" is an alias for "gbr --no-convention".

```sh
alias gbr_="gbr --no-convention"
```

### `gbs`

"gbs" is short for "git branch squash", which squashes all commits on the branch.

### `gc`

"gc" is short for "git commit", which will perform all the steps involved in making a new commit
with all unstaged changes. The arguments that are provided will be the commit message. If no
arguments are provided, then the script will attempt to find a suitable commit message.

### `_gc`

Splitting the logic into a separate function like this is necessary to prevent the bug where doing
"gc" in a directory that does not yet exist on the upstream will throw an error.

### `gca`

"gca" is short for "git commit amend". This is similar to "gc", but it will amend the previous
commit and add all unstaged files. Use this sparingly, since it will force push. By default, it
will use the previous commit message, but you can use "gca edit" (or "gcam") to edit the commit
message before pushing.

### `gcam`

"gcam" is short for "git commit amend message". This is similar to "gca", but it will also allow
you to change the commit message. If arguments are provided, they are used as the commit message.

### `gcl`

"gcl" is short for "git clone". (We do not use a subshell because we need to change the current
working directory.)

### `gcm`

"gcm" is short for "git commit main". It is intended to be used in a worktree with a detached
HEAD. It is similar to "gc", but it will commit all unstaged changes directly to the main (or
master) branch on the remote.

### `_gcm`

_(undocumented)_

### `gcp`

"gcp" is short for "git cherry-pick".

### `gcpa`

"gcpa" is short for "git cherry-pick --abort".

```sh
alias gcpa="git cherry-pick --abort"
```

### `gcpc`

"gcpc" is short for "git cherry-pick --continue".

```sh
alias gcpc="git cherry-pick --continue"
```

### `gcpr`

"gcpr" will both commit and open a pull request.

### `gcs`

"gcs" is short for "git commit show", which will open a browser to view the last commit. You can
optionally supply a SHA1 to show a custom commit.

### `gcu`

"gcu" is short for "git commit undo", which will undo the last commit locally (but not on the
remote). You can also provide a number argument to undo the last N commits.

### `gd`

"gd" is short for "git diff".

```sh
alias gd="git diff"
```

### `gl`

"gl" is short for "git log".

```sh
alias gl="git log"
```

### `glg`

"glg" is short for "git log --graph" with specific formatting.

```sh
alias glg="git log --graph --pretty=format:'%C(yellow)%h%Creset %C(cyan)%d%Creset %C(white)%s%Creset %C(green)(%an)%Creset%n%w(0,8,8)%b%Creset' --all --decorate"
```

### `gmc`

"gmc" is short for "git merge conflicts", which will show the files that need to be resolved
before the merge/rebase/whatever can proceed.

```sh
alias gmc="git diff --name-only --diff-filter=U"
```

### `gmco`

"gmco" is short for "git merge conflicts open", which is similar to "gmc", but will open all of
the files that need to be resolved in Visual Studio Code.

### `gp`

"gp" is short for "git pull". Detached worktrees fast-forward to the remote main branch.

### `gpm`

"gpm" is short for "git pull mine", which will fetch all remote branches that start with
"feature/misc/[username]/" and create local tracking branches for them if they do not already
exist.

### `gpr`

"gpr" is short for "git pull request", to start a new pull request based on the current branch.
The arguments that are provided will be the pull request title. If no arguments are provided, then
the script will attempt to find a suitable pull request title. You can use the "--check" flag to
only check whether a pull request already exists.

### `gpro`

"gpro" is short for "git pull request open".

### `gpr-dry`

"gpr-dry" is similar to "gpr", but will just open the URL that will begin the process of creating
the pull request instead of actually fully opening the pull request. This is useful to see the
files changed on the branch.

### `gprf`

"gprf" is short for "git pull request fix".

### `gprh`

"gprh" is short for "git pull request hack".

### `gprp`

"gprp" is short for "git pull request push".

### `grb`

"grb" is short for "git rebase".

```sh
alias grb="git rebase"
```

### `grba`

"grba" is short for "git rebase --abort".

```sh
alias grba="git rebase --abort"
```

### `grbc`

"grbc" is short for "git rebase --continue". (It will automatically add all files for you.)

### `grbm`

"grbm" is short for "git rebase main".

### `grm`

"grm" is short for "git remote -v".

```sh
alias grm="git remote -v"
```

### `grms`

"grms" is short for "git remote ssh", which changes the current Git remote from HTTPS to SSH.

### `grs`

"grs" is short for "git reset".

```sh
alias grs="git reset"
```

### `grsh`

"grsh" is short for "git reset --hard".

```sh
alias grsh="git reset --hard"
```

### `grshm`

"grshm" is short for "git reset --hard origin/main".

### `grt`

"grt" is short for "git restore".

### `grv`

"grv" is short for "git revert".

### `grva`

"grva" is short for "git revert --abort".

```sh
alias grva="git revert --abort"
```

### `grvc`

"grvc" is short for "git revert --continue". (It will automatically add all files for you.)

### `grvl`

"grvl" is short for "git revert last".

### `gs`

"gs" is short for "git status --porcelain". (The "--porcelain" flag is preferred since the output
is more terse.)

```sh
alias gs="git status --porcelain"
```

### `gsh`

"gsh" is short for "git show".

```sh
alias gsh="git show"
```

### `gsq`

"gsq" stands for "git squash", to squash N commits together.

### `gsp`

"gsp" is short for "git split", which moves changes for a file path or commit to a new branch and
then removes those changes from the current branch.

### `gst`

"gst" is short for "git stash".

```sh
alias gst="git stash"
```

### `gstd`

"gstd" is short for "git stash drop".

```sh
alias gstd="git stash drop"
```

### `gstl`

"gstl" is short for "git stash list".

```sh
alias gstl="git stash list"
```

### `gstp`

"gstp" is short for "git stash pop"

```sh
alias gstp="git stash pop"
```

### `gsw`

"gsw" is short for "git switch". It requires an argument of the number corresponding to the
alphabetical local branch. ("gs" is already taken by another command.)

### `gsww`

"gsww" is short for "git switch workspace". It requires an argument of the number corresponding to
the worktree. (We do not use a subshell because we need to change the current working directory.)

### `gswc`

"gswc" is short for "git switch -c". (However, the "gb" command should be used in most contexts.)

```sh
alias gswc="git switch -c"
```

### `gswm`

"gswm" is short for "git switch main". Linked worktrees detach at the remote main branch.

### `gtc`

"gtc" is short for "git tags clean", which will remote all local tags that do not exist on the
remote repository.
<https://stackoverflow.com/questions/1841341/remove-local-git-tags-that-are-no-longer-on-the-remote-repository>

### `gu`

"gu" is short for "git push".

```sh
alias gu="git push"
```

### `guf`

"guf" is short for "git push --force-with-lease".

```sh
alias guf="git push --force-with-lease"
```

### `guo`

"guo" is short for "git unclean open", which will open all of the unstaged modified and untracked
files in this repository inside Visual Studio Code. This command will throw an error if there are 10
or more changed files.

### `gwa`

"gwa" is short for "git worktree add". Creates a detached worktree in a numbered directory.
We do not use a subshell because we need to change the current working directory.

### `gwd`

"gwd" is short for "git worktree delete". (Even though the real command is "git worktree remove",
we use "gwd" to maintain parity with "gbd".) If the worktree branch has no commits beyond its merge
base with the main branch, the branch will also be deleted. (We do not use a subshell because we
need to change the current working directory when deleting the current worktree.)

### `gwl`

"gwl" is short for "git worktree list".

## Github

_Source: `github.sh`_

### `gh-clean`

This will delete local branches that have been merged via pull requests on GitHub.

### `gh-pr`

This is a custom version of "gh pr checkout". This is necessary because "gh pr checkout" will fail
if the forked repository branch name overlaps with a branch name on the upstream repository (and
the remote has already been added by "set-gh-remote"). To work around this, we can checkout the
forked repository branch with a custom arbitrary name matching the pull request number.

### `gh-sync`

This will sync a forked repository's main branch with the upstream. (This is a common operation
when working on GitHub.)

## Kubectl

_Source: `kubectl.sh`_

### `k`

Shortcut for `kubectl`.

```sh
alias k="kubectl"
```

### `kdd`

Shortcut for `kubectl describe deployment`.

```sh
alias kdd="kubectl describe deployment"
```

### `kdp`

Shortcut for `kubectl describe pod`.

```sh
alias kdp="kubectl describe pod"
```

### `kds`

Shortcut for `kubectl describe service`.

```sh
alias kds="kubectl describe service"
```

### `kgd`

Shortcut for `kubectl get deployment`.

```sh
alias kgd="kubectl get deployment"
```

### `kgp`

Shortcut for `kubectl get pod`.

```sh
alias kgp="kubectl get pod"
```

## Miscellaneous

_Source: `miscellaneous.sh`_

### `ah`

"ah" is short for "Azure DevOps history". Opens the Azure DevOps URL for the "History" tab of the
corresponding file.

### `azl`

"azl" is short for "az login". We use a custom browser profile to bypass the account picker.

### `azwhoami`

Shortcut for `az account show --query user.name -o tsv`.

```sh
alias azwhoami="az account show --query user.name -o tsv"
```

### `bwl`

"bwl" is short for "bw login --apikey". (This is the BitWarden CLI.)

```sh
alias bwl="bw login --apikey"
```

### `canary`

_(undocumented)_

### `clip`

"clip" is a Windows utility that puts input into the clipboard.

```sh
alias clip="clip.exe"
```

### `co`

"co" is short for "copilot". (See below.)

```sh
alias co="copilot"
```

### `code`

_(undocumented)_

### `cod`

"cod" is short for "codex".

```sh
alias cod="codex"
```

### `codex`

Turn off Codex CLI prompts.

```sh
alias codex="codex --yolo"
```

### `configs`

Reload these Bash configs.

```sh
alias configs="source "$REPOSITORIES_DIR/configs/bash/bashrc.sh""
```

### `copilot`

Turn off GitHub Copilot CLI prompts.

```sh
alias copilot="GITHUB_TOKEN=\${GITHUB_TOKEN_WORK:-\$GITHUB_TOKEN} copilot --yolo --no-ask-user"
```

### `cl`

"cl" is short for "claude".

```sh
alias cl="claude"
```

### `claude`

Turn off Claude Code prompts.

```sh
alias claude="claude --dangerously-skip-permissions"
```

### `csf`

"csf" is short for "CSpell fix", which will invoke "cspell-check-unused-words --fix".

### `decrypt`

_(undocumented)_

### `encrypt`

_(undocumented)_

### `eslint-open`

_(undocumented)_

### `full-path`

Shortcut for `readlink -f`.

```sh
alias full-path="readlink -f"
```

### `get-env`

We do not use a subshell because the "source" would not work.

### `gemini`

Turn off Gemini Code Assist prompts.

```sh
alias gemini="gemini --yolo"
```

### `get-ssh-keys`

_(undocumented)_

### `kb`

"kb" is short for "kubernetes build".

### `killapp`

_(undocumented)_

### `ll`

A better "ll" alias that shows human-readable file sizes.
(macOS does not support any of the long-form flags, so we use the short ones instead.)

- "-a" is short for "--all", which shows hidden files.
- "-h" is short for "--human-readable", which converts bytes to kilobytes and so on.
- "-F" is short for "--classify", which displays extra characters to signify the file type.
- "--color=auto" makes Ubuntu have the same colors that Git Bash for Windows does.

```sh
alias ll="ls -a -h -l -F --color=auto"
```

### `llm`

Ask an LLM a question from the terminal.

### `minionpass`

_(undocumented)_

### `n`

"n" is short for "nuke".

```sh
alias n="bunx complete-cli@latest nuke"
```

### `o`

"o" is short for "open", to open a URL in a browser.

### `oc`

"oc" is short for "opencode". The "--auto" flag is needed to turn off the prompts.

```sh
alias oc="opencode"
```

### `opencode`

Turn off OpenCode prompts.

```sh
alias opencode="opencode --auto"
```

### `pi`

"pi" is short for "pipeline info".

### `pip`

Shortcut for `python -m pip`.

```sh
alias pip="python -m pip"
```

### `set-claude-settings`

_(undocumented)_

### `set-env`

Shortcut for `encrypt "$HOME/.env"`.

```sh
alias set-env="encrypt "$HOME/.env""
```

### `start`

Alias "start" to "open" on macOS and "xdg-open" on Linux. ("start" is a Windows-only command to
open explorer at the given path.)

### `tpr`

"tpr" is short for "test-pr".

### `vim`

We disable the mouse because it prevents highlighting text and pressing enter to copy it to the
clipboard.

```sh
alias vim="vim -c 'set mouse="
```

### `vpn`

Kills and restarts Palo Alto GlobalProtect.

### `vpnr`

"vpnr" stands for "vpn routes".

```sh
alias vpnr="sudo /usr/local/sbin/add-routes"
```

## Npm

_Source: `npm.sh`_

### `exec-package`

_(undocumented)_

### `get-package-manager`

_(undocumented)_

### `run-package-script`

_(undocumented)_

### `b`

Shortcut for `run-package-script build`.

```sh
alias b="run-package-script build"
```

### `d`

Shortcut for `run-package-script dev`.

```sh
alias d="run-package-script dev"
```

### `l`

Shortcut for `run-package-script lint`.

```sh
alias l="run-package-script lint"
```

### `la`

Shortcut for `run-package-script lint-all`.

```sh
alias la="run-package-script lint-all"
```

### `p`

Shortcut for `run-package-script publish`.

```sh
alias p="run-package-script publish"
```

### `s`

Shortcut for `run-package-script start`.

```sh
alias s="run-package-script start"
```

### `t`

Shortcut for `run-package-script test`.

```sh
alias t="run-package-script test"
```

### `u`

If the "package.json" file for the project has an "update" script, then run the script. Otherwise,
invoke the "update" command of "complete-cli".

## Pulumi

_Source: `pulumi.sh`_

### `pc`

"pc" is short for "pulumi cancel". (This is the analog to "terraform force-unlock".)

```sh
alias pc="pulumi cancel"
```

### `pd`

"pd" is short for "pulumi destroy".

```sh
alias pd="pulumi destroy"
```

### `pl`

"pl" is short for "pulumi login".

```sh
alias pl="pulumi login azblob://pulumi-state?storage_account=lhdevopstfstate"
```

### `pp`

"pp" is short for "pulumi preview".

```sh
alias pp="pulumi preview"
```

### `ppf`

"ppf" is short for "terraform pipeline fix". This is the analog to "tph"; it will put the
"pulumi-preview-approve-up.yml" file back to normal.

### `pph`

"pph" is short for "pulumi pipeline hack". It will edit the "pulumi-preview-approve-up.yml" file
for the current feature branch.

### `pr`

"pr" is short for "pulumi refresh". Note that this will overwrite the existing "pr" command:
<https://man7.org/linux/man-pages/man1/pr.1.html>

```sh
alias pr="pulumi refresh"
```

### `pu`

"pu" is short for "pulumi up --suppress-outputs".

```sh
alias pu="pulumi up --suppress-outputs"
```

### `puy`

"puy" is short for "pulumi up --yes".

```sh
alias puy="pulumi up --yes"
```

## Say

_Source: `say.sh`_

### `say`

_(undocumented)_

## Ssh

_Source: `ssh.sh`_

### `sshh`

Shortcut for `ssh root@hanab.live`.

```sh
alias sshh="ssh root@hanab.live"
```

### `sshi`

Shortcut for `ssh root@isaacracing.net`.

```sh
alias sshi="ssh root@isaacracing.net"
```

## Terraform

_Source: `terraform.sh`_

### `ta`

"ta" is short for "terraform apply".

```sh
alias ta="terraform apply"
```

### `taa`

"taa" is short for "terraform apply -auto-approve".

```sh
alias taa="terraform apply -auto-approve"
```

### `tc`

"tc" is short for "terraform clean".

```sh
alias tc="rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup"
```

### `td`

"td" is short for "terraform destroy".

```sh
alias td="terraform destroy"
```

### `tdf`

"tdf" is short for "terraform docs fix". It will infer all of the Terraform modules modified in
the current feature branch.

### `tpf`

"tpf" is short for "terraform pipeline fix". This is the analog to "tph"; it will put the
"terraform-plan-approve-apply.yml" file back to normal.

### `tph`

"tph" is short for "terraform pipeline hack". It will edit the "terraform-plan-approve-apply.yml"
file for the current feature branch.

### `tda`

"tda" is short for "terraform destroy -auto-approve".

```sh
alias tda="terraform destroy -auto-approve"
```

### `tf`

"tf" is short for "terraform fmt".

```sh
alias tf="terraform fmt"
```

### `ti`

"ti" is short for "terraform init".

```sh
alias ti="terraform init"
```

### `tib`

"tib" is short for "terraform init backend", which is useful for running "terraform init" on the
existing "config.azurerm.tfbackend" file.

### `tie`

"tie" is short for "terraform init empty", which is useful for running "terraform init" without
intending to deploy anything.

```sh
alias tie="terraform init -backend=false"
```

### `tiv`

"tiv" is short for "terraform init && terraform validate".

```sh
alias tiv="terraform init && terraform validate"
```

### `tl`

"tl" is short for "tflint".

```sh
alias tl="tflint"
```

### `tp`

"tp" is short for "terraform plan".

```sh
alias tp="terraform plan"
```

### `tt`

"tt" is short for "terraform test".

```sh
alias tt="terraform test"
```

### `tu`

"tu" is short for "terraform force-unlock -force".

```sh
alias tu="terraform force-unlock -force"
```

### `tv`

"tv" is short for "terraform validate".

```sh
alias tv="terraform validate"
```

## Personal Overrides (this repo)

_Source: `bashrc_local.sh`_

### `r`

Shortcut for `cd $HOME/Repositories`.

```sh
alias r="cd $HOME/Repositories"
```
