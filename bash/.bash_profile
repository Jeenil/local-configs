# Load the commands from the local "configs" repository clone.
CONFIGS_REPO_PATH="$HOME/repositories/configs"

# Initialize fnm before sourcing bashrc.sh so the Linux npm is on PATH first.
# Without this, WSL finds Windows npm before the fnm-managed one, causing
# "npm completion" in bashrc.sh to fail with a MINGW-only error.
FNM_PATH="$HOME/.local/share/fnm"
if [[ -d "$FNM_PATH" ]]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell bash 2>/dev/null)" 2>/dev/null || true
fi

# shellcheck source=/dev/null
source "$CONFIGS_REPO_PATH/bash/bashrc.sh"

# Load personal overrides and additions.
# shellcheck source=/dev/null
if [[ -s "$HOME/.bashrc_local.sh" ]]; then
  source "$HOME/.bashrc_local.sh"
fi
