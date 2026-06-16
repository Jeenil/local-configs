# Personal bash additions on top of Jeenil/configs.

# Load env vars (API keys, tokens, etc.) decrypted from the secrets repo during setup.
if [[ -s "$HOME/.env" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.env"
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

# Windows-only settings (Git Bash).
if [[ "${OS:-}" == "Windows_NT" ]]; then
  export CLAUDE_CODE_GIT_BASH_PATH="C:\\Users\\jeepatel.CORP\\AppData\\Local\\Programs\\Git\\bin\\bash.exe"
  export PATH="$PATH:/c/Users/jeepatel/AppData/Roaming/Python/Python313/Scripts"
fi
