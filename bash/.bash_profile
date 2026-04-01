# Load the commands from the "configs" GitHub repository.
# Load the commands from the "configs" GitHub repository.
mkdir -p ~/.config
BASH_PROFILE_REMOTE_PATH=~/.config/.bash_profile_remote
rm -f "$BASH_PROFILE_REMOTE_PATH"
curl --silent --fail --show-error --output "$BASH_PROFILE_REMOTE_PATH" https://raw.githubusercontent.com/Zamiell/configs/refs/heads/main/bash/.bash_profile_remote

export CLAUDE_CODE_GIT_BASH_PATH="C:\\Users\\jeepatel.CORP\\AppData\\Local\\Programs\\Git\\bin\\bash.exe"

# shellcheck source=/dev/null
source "$BASH_PROFILE_REMOTE_PATH"
#cp /c/repositories/configs/bash/.bash_profile_remote "$BASH_PROFILE_REMOTE_PATH"

# shellcheck source=/dev/null
source "$BASH_PROFILE_REMOTE_PATH"

export PATH="$PATH:/c/Users/jeepatel/AppData/Roaming/Python/Python313/Scripts"



# Cross-platform repository shortcut
# Checks common locations on Windows, Mac, and Linux
if [ -d "$HOME/Repositories" ]; then
    alias r="cd $HOME/Repositories"
elif [ -d "$HOME/repositories" ]; then
    alias r="cd $HOME/repositories"
elif [ -d "/c/repositories" ]; then
    alias r="cd /c/repositories"
elif [ -d "/c/repos" ]; then
    alias r="cd /c/repos"
fi

# Claude Code - separate config dirs per account
# Usage: claude-personal | claude-work
# First-time setup: run `claude-personal auth login` and `claude-work auth login`
export CLAUDE_CONFIG_DIR_PERSONAL="C:\\Users\\jeepatel\\AppData\\Roaming\\claude-personal"
export CLAUDE_CONFIG_DIR_WORK="C:\\Users\\jeepatel.CORP\\AppData\\Roaming\\claude-work"
alias claude-personal='CLAUDE_CONFIG_DIR="$CLAUDE_CONFIG_DIR_PERSONAL" claude'
alias claude-work='CLAUDE_CONFIG_DIR="$CLAUDE_CONFIG_DIR_WORK" claude'

