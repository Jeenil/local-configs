# Personal bash additions on top of Jeenil/configs.

# Load env vars (API keys, tokens, etc.) decrypted from the secrets repo during setup.
if [[ -s "$HOME/.env" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.env"
fi

# GitHub Copilot token for the LLM-powered commands (e.g. "gc"'s auto commit
# messages via api.githubcopilot.com). Do NOT export GITHUB_TOKEN here: gh treats
# that variable as the active account, so exporting it makes "gh auth switch" and
# "gh auth login" fail until it is unset. configs/bash/helper-functions.sh's
# get-github-token resolves the token from `gh auth token` on demand instead, so
# the LLM commands always follow whichever account gh is currently logged in as.
# The one state still worth warning about is a personal access token in ~/.env:
# it takes precedence over gh's OAuth token, and the Copilot API rejects all PATs.
if [[ "${GITHUB_TOKEN:-}" == ghp_* || "${GITHUB_TOKEN:-}" == github_pat_* ]] && [[ $- == *i* ]]; then
  echo "⚠️  gc: GITHUB_TOKEN is a Personal Access Token, which the Copilot API" >&2
  echo "    rejects — 'gc' commit messages will fail. Remove it (your gh OAuth" >&2
  echo "    token works and is used automatically):" >&2
  echo "      sed -i -E '/^[[:space:]]*(export[[:space:]]+)?GITHUB_TOKEN=/d' ~/.env" >&2
  echo "      then open a new terminal, or: unset GITHUB_TOKEN" >&2
fi

# Work-specific additions live in the private "secrets" repository.
if [[ -s "$HOME/repositories/secrets/work/bashrc_work.sh" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/repositories/secrets/work/bashrc_work.sh"
fi

# Cross-platform repository shortcut.
if [ -d "$HOME/Repositories" ]; then
    alias r="cd $HOME/Repositories"
elif [ -d "$HOME/repositories" ]; then
    alias r="cd $HOME/repositories"
elif [ -d "/c/repositories" ]; then
    alias r="cd /c/repositories"
elif [ -d "/c/repos" ]; then
    alias r="cd /c/repos"
fi

# Personal tool paths. prepend-path (from configs/bash/helper-functions.sh) only adds a
# directory that exists and is not already on PATH, so this is duplicate-safe.
prepend-path "$HOME/.pulumi/bin"

# WSL-only settings. (Lives here rather than ~/.bashrc so login shells, which
# do not source ~/.bashrc, still get them.)
if command -v is-wsl > /dev/null 2>&1 && is-wsl; then
  export BROWSER=wslview
fi
