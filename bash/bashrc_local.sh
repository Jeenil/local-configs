# Personal bash additions on top of Jeenil/configs.

export CLAUDE_CODE_GIT_BASH_PATH="C:\\Users\\jeepatel.CORP\\AppData\\Local\\Programs\\Git\\bin\\bash.exe"

export PATH="$PATH:/c/Users/jeepatel/AppData/Roaming/Python/Python313/Scripts"

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

# Claude Code - separate config dirs per account.
# Usage: claude-personal | claude-work
# First-time setup: run `claude-personal auth login` and `claude-work auth login`
export CLAUDE_CONFIG_DIR_PERSONAL="C:\\Users\\jeepatel\\AppData\\Roaming\\claude-personal"
export CLAUDE_CONFIG_DIR_WORK="C:\\Users\\jeepatel.CORP\\AppData\\Roaming\\claude-work"
alias claude-personal='CLAUDE_CONFIG_DIR="$CLAUDE_CONFIG_DIR_PERSONAL" claude'
alias claude-work='CLAUDE_CONFIG_DIR="$CLAUDE_CONFIG_DIR_WORK" claude'
