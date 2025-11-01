# Inherit upstream config.
mkdir ~/.config --parents
BASH_PROFILE_REMOTE_PATH=~/.config/.bash_profile_remote
rm -f "$BASH_PROFILE_REMOTE_PATH"
curl https://raw.githubusercontent.com/Zamiell/configs/refs/heads/main/bash/.bash_profile_remote --silent --output "$BASH_PROFILE_REMOTE_PATH"
source "$BASH_PROFILE_REMOTE_PATH"


# Repository shortcut
alias r="cd /c/repositories"

# SSH key setup
alias setup-ssh="bash C/repositories/tmp/setup_ssh.sh"
