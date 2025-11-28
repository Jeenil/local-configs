# Load the commands from the "configs" GitHub repository.
mkdir -p ~/.config
BASH_PROFILE_REMOTE_PATH=~/.config/.bash_profile_remote
rm -f "$BASH_PROFILE_REMOTE_PATH"
curl --silent --fail --show-error --output "$BASH_PROFILE_REMOTE_PATH" https://raw.githubusercontent.com/Zamiell/configs/refs/heads/main/bash/.bash_profile_remote
# shellcheck source=/dev/null
source "$BASH_PROFILE_REMOTE_PATH"

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

# Custom additions for this machine
# Suppress bash deprecation warning on macOS
export BASH_SILENCE_DEPRECATION_WARNING=1

# Node.js path (if using Homebrew on Mac)
if [ -d "/opt/homebrew/opt/node@22/bin" ]; then
    export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
fi
