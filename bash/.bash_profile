# Load the commands from the "configs" GitHub repository.
# bashrc.sh sources bun-completions.sh via $DIR, so both must live in the same directory.
CONFIGS_BASH_DIR=~/.config/jeenil-configs/bash
mkdir -p "$CONFIGS_BASH_DIR"
CONFIGS_BASE_URL="https://raw.githubusercontent.com/Jeenil/configs/refs/heads/main/bash"
curl --silent --fail --show-error --output "$CONFIGS_BASH_DIR/bashrc.sh" "$CONFIGS_BASE_URL/bashrc.sh"
curl --silent --fail --show-error --output "$CONFIGS_BASH_DIR/bun-completions.sh" "$CONFIGS_BASE_URL/bun-completions.sh"

# shellcheck source=/dev/null
source "$CONFIGS_BASH_DIR/bashrc.sh"

# Load personal overrides and additions.
# shellcheck source=/dev/null
source ~/.bashrc_local.sh
