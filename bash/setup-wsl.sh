#!/bin/bash

set -euo pipefail # Exit on errors and undefined variables.

if [[ ! -s "/etc/os-release" ]]; then
  echo "Error: This script is intended to be run inside Ubuntu WSL (Windows Subsystem for Linux)." >&2
  exit
fi

# shellcheck source=/dev/null
source /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
  echo "Error: This script is intended to be run inside Ubuntu WSL (Windows Subsystem for Linux)." >&2
  exit
fi

# -----------
# Constants
# -----------

FULL_NAME="Jeenil Patel"
WORK_EMAIL="jpatel@logixhealth.com"
GITHUB_USERNAME="Jeenil"
WINDOWS_USERNAME="jeepatel.CORP"

# -----------
# Subroutines
# -----------

clone-work-repo() {
  if [[ -z "${1:-}" ]]; then
    echo "You must pass the repository URL as the first argument." >&2
    return 1
  fi
  local repository_url="$1"

  local directory_name="${repository_url##*/}"
  if [[ -z "$directory_name" ]]; then
    echo "Failed to derive the repository directory name from the repository URL of: $repository_url" >&2
    return 1
  fi

  local repository_path="$REPOSITORIES_DIR/$directory_name"
  if [[ ! -d "$repository_path" ]]; then
    git clone "$repository_url" "$repository_path"
    if is-jeepatel; then
      git -C "$repository_path" config user.name "$FULL_NAME"
      git -C "$repository_path" config user.email "$WORK_EMAIL"
    fi
  fi
}

is-jeepatel() {
  [[ "$USER" == "jeepatel" ]]
}

get-github-latest-release-url() {
  local repository="$1"
  if [[ -z "$repository" ]]; then
    echo "You must pass this function the GitHub author and repository name as the first argument." >&2
    exit 1
  fi

  local filename_template="$2"
  if [[ -z "$filename_template" ]]; then
    echo "You must pass this function the filename template as the second argument." >&2
    exit 1
  fi

  local latest_release_json
  latest_release_json=$(curl --silent --fail --show-error --location "https://api.github.com/repos/${repository}/releases/latest")

  local tag_name
  tag_name=$(jq --raw-output '.tag_name' <<< "$latest_release_json")

  # Check if TAG_NAME is empty or literal "null" (which jq returns if the key is missing).
  if [[ -z "$tag_name" ]] || [[ "$tag_name" == "null" ]]; then
    echo "Failed to fetch the latest version of: $repository" >&2
    exit 1
  fi

  local version
  version="${tag_name#v}"

  local filename
  filename="${filename_template//\{tag_name\}/$tag_name}"
  filename="${filename//\{version\}/$version}"
  echo "https://github.com/${repository}/releases/download/${tag_name}/${filename}"
}

install-binary-from-tar-url() {
  local download_url="$1"
  if [[ -z "$download_url" ]]; then
    echo "You must pass this function the tar download URL as the first argument." >&2
    exit 1
  fi

  local binary_name="$2"
  if [[ -z "$binary_name" ]]; then
    echo "You must pass this function the binary name as the second argument." >&2
    exit 1
  fi

  local filename
  filename="${download_url##*/}"

  local tmp_path
  tmp_path="/tmp/$filename"

  curl --silent --fail --show-error --location --output "$tmp_path" "$download_url"
  tar -xzf "$tmp_path" -C /tmp
  sudo mv "/tmp/$binary_name" /usr/local/bin/
  rm "$tmp_path"
}

# ----------
# Main setup
# ----------

# Update.
sudo apt-get update
sudo apt-get upgrade --yes
sudo apt-get install --yes \
  age \
  bind9-dnsutils \
  jq \
  podman \
  python-is-python3 \
  ripgrep \
  shellcheck \
  unzip

# Set up SSH.
SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
if is-jeepatel; then
  if [[ ! -s "$SSH_DIR/id_ed25519" ]] && [[ -f "/mnt/c/Users/$WINDOWS_USERNAME/.ssh/id_ed25519" ]]; then
    cp "/mnt/c/Users/$WINDOWS_USERNAME/.ssh/id_ed25519" "$SSH_DIR/id_ed25519"
    chmod 600 "$SSH_DIR/id_ed25519"
  fi
  if [[ ! -s "$SSH_DIR/id_ed25519.pub" ]] && [[ -f "/mnt/c/Users/$WINDOWS_USERNAME/.ssh/id_ed25519.pub" ]]; then
    cp "/mnt/c/Users/$WINDOWS_USERNAME/.ssh/id_ed25519.pub" "$SSH_DIR/id_ed25519.pub"
  fi
  mkdir -p "$SSH_DIR/work"
  if [[ ! -s "$SSH_DIR/work/id_rsa.pub" ]] && [[ -f "/mnt/c/Users/$WINDOWS_USERNAME/.ssh/id_rsa.pub" ]]; then
    cp "/mnt/c/Users/$WINDOWS_USERNAME/.ssh/id_rsa.pub" "$SSH_DIR/work/id_rsa.pub"
  fi
fi

# Set up company certificates.
# Download from GitHub (avoids the chicken-and-egg of fetching from a corp URL before the cert is trusted).
CERT_PATH="/usr/local/share/ca-certificates/BEDROOTCA001.crt"
if [[ ! -s "$CERT_PATH" ]]; then
  sudo curl --silent --fail --show-error --location "https://raw.githubusercontent.com/$GITHUB_USERNAME/configs/refs/heads/main/certs/BEDROOTCA001.crt" --output "$CERT_PATH" && sudo update-ca-certificates
fi

# Clone personal repositories.
# Use HTTPS for configs so it works on fresh machines without SSH keys set up yet.
REPOSITORIES_DIR="$HOME/repositories"
mkdir -p "$REPOSITORIES_DIR"
cd "$REPOSITORIES_DIR"
if [[ ! -d "$REPOSITORIES_DIR/configs" ]]; then
  git clone "https://github.com/$GITHUB_USERNAME/configs.git"
  git -C "$REPOSITORIES_DIR/configs" config user.name "$FULL_NAME"
  git -C "$REPOSITORIES_DIR/configs" config user.email "$WORK_EMAIL"
fi
if is-jeepatel; then
  if ! ssh-keygen -F github.com &> /dev/null; then
    ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2> /dev/null
  fi
  if [[ ! -d "$REPOSITORIES_DIR/local-configs" ]]; then
    git clone "git@github.com:$GITHUB_USERNAME/local-configs.git"
    git -C "$REPOSITORIES_DIR/local-configs" config user.name "$FULL_NAME"
    git -C "$REPOSITORIES_DIR/local-configs" config user.email "$WORK_EMAIL"
  fi
  if [[ ! -d "$REPOSITORIES_DIR/secrets" ]]; then
    git clone "git@github.com:$GITHUB_USERNAME/secrets.git"
    git -C "$REPOSITORIES_DIR/secrets" config user.name "$FULL_NAME"
    git -C "$REPOSITORIES_DIR/secrets" config user.email "$WORK_EMAIL"
  fi
fi

# Load Git settings.
"$REPOSITORIES_DIR/configs/bash/other/set-git-settings.sh"
if is-jeepatel; then
  git config --global user.name "$FULL_NAME"
  git config --global user.email "$WORK_EMAIL"
fi

# Set up SSH config and decrypt secrets.
if is-jeepatel; then
  # Copy SSH config (uses ~ so it's not username-specific).
  cp "$REPOSITORIES_DIR/local-configs/bash/ssh-config" "$SSH_DIR/config"
  chmod 600 "$SSH_DIR/config"

  # Decrypt env vars (API keys, tokens, etc.) from the encrypted secrets repo.
  if age --decrypt --identity "$SSH_DIR/id_ed25519" --output "$HOME/.env" "$REPOSITORIES_DIR/secrets/.env.age" 2>/dev/null; then
    chmod 600 "$HOME/.env"
  else
    echo "Warning: could not decrypt secrets — SSH key on this machine may not be a recipient. Skipping." >&2
  fi

  # Decrypt the work SSH private key.
  if age --decrypt --identity "$SSH_DIR/id_ed25519" --output "$SSH_DIR/work/id_rsa" "$REPOSITORIES_DIR/secrets/id_rsa.age" 2>/dev/null; then
    chmod 600 "$SSH_DIR/work/id_rsa"
  else
    echo "Warning: could not decrypt work SSH key — skipping." >&2
  fi
fi

# Load the Bash configs.
BASHRC_PATH="$HOME/.bashrc"

# Patch existing .bashrc files: insert fnm init before the configs source if missing.
if grep --quiet 'CONFIGS_REPO_PATH=' "$BASHRC_PATH" && ! grep --quiet 'local/share/fnm' "$BASHRC_PATH"; then
  sed --in-place 's|^CONFIGS_REPO_PATH=|# Initialize fnm (Node.js version manager) before loading configs that run npm.\nFNM_PATH="$HOME/.local/share/fnm"\nif [[ -d "$FNM_PATH" ]]; then\n  export PATH="$FNM_PATH:$PATH"\n  eval "$(fnm env --shell bash)"\nfi\n\nCONFIGS_REPO_PATH=|' "$BASHRC_PATH"
fi

if ! grep --quiet "Load the commands from the \"configs\"" "$BASHRC_PATH"; then
  # shellcheck disable=SC2016
  echo '
# Initialize fnm (Node.js version manager) before loading configs that run npm.
FNM_PATH="$HOME/.local/share/fnm"
if [[ -d "$FNM_PATH" ]]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell bash)"
fi

# Load the commands from the "configs" GitHub repository: https://github.com/Jeenil/configs
CONFIGS_REPO_PATH="$HOME/repositories/configs"
# shellcheck source=/dev/null
source "$CONFIGS_REPO_PATH/bash/bashrc.sh"

# Load personal overrides and additions.
# shellcheck source=/dev/null
if [[ -s "$HOME/.bashrc_local.sh" ]]; then
  source "$HOME/.bashrc_local.sh"
fi
' >> "$BASHRC_PATH"
fi

# Install personal Bash overrides.
if is-jeepatel; then
  cp "$REPOSITORIES_DIR/local-configs/bash/.bash_profile" "$HOME/.bash_profile"
  cp "$REPOSITORIES_DIR/local-configs/bash/bashrc_local.sh" "$HOME/.bashrc_local.sh"
fi

# Clone work repositories.
if ! ssh-keygen -F azuredevops.logixhealth.com &> /dev/null; then
  ssh-keyscan azuredevops.logixhealth.com >> "$HOME/.ssh/known_hosts" 2> /dev/null
fi
clone-work-repo "ssh://azuredevops.logixhealth.com:22/LogixHealth/Infrastructure/_git/infrastructure"

# -----------------------------
# Install programming languages
# -----------------------------


# Install fnm.
# https://github.com/Schniz/fnm
if ! command -v fnm &> /dev/null; then
  # The "--skip-shell" is necessary to prevent fnm from modifying the ".bashrc" file.
  curl --silent --fail --show-error --location https://fnm.vercel.app/install | bash -s -- --skip-shell

  # Add it to PATH for the current session.
  FNM_PATH="$HOME/.local/share/fnm"
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell bash)"
fi

# Install Node.js via fnm. Don't guard with "command -v node" — Windows node bleeds into WSL
# PATH via interop and would cause this to be skipped, leaving fnm with no version installed.
if command -v fnm &> /dev/null; then
  fnm install --lts
fi

# Install Bun.
# https://bun.sh/
if ! command -v bun &> /dev/null; then
  curl --silent --fail --show-error --location https://bun.sh/install | bash
fi

# Add bun to PATH for the current session (the installer only modifies .bashrc).
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Install uv.
# https://docs.astral.sh/uv/getting-started/installation/
if ! command -v uv &> /dev/null; then
  curl --silent --fail --show-error --location https://astral.sh/uv/install.sh | sh
fi

# Install PowerShell.
# https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu
if ! command -v pwsh &> /dev/null; then
  DEB_PATH="/tmp/packages-microsoft-prod.deb"
  # Microsoft's package repo lags Ubuntu releases; use the latest supported LTS version.
  PWSH_UBUNTU_VERSION="24.04"
  curl --silent --fail --show-error --location --output "$DEB_PATH" "https://packages.microsoft.com/config/ubuntu/$PWSH_UBUNTU_VERSION/packages-microsoft-prod.deb"
  sudo dpkg --install "$DEB_PATH"
  rm "$DEB_PATH"
  sudo apt-get update
  sudo apt-get install powershell --yes
fi

# Install Terraform.
# https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
if ! command -v terraform &> /dev/null; then
  curl --silent --fail --show-error --location https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
  # HashiCorp's repo lags Ubuntu releases; use the latest supported LTS codename.
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt-get update
  sudo apt-get install terraform --yes
fi

# Install `terraform-docs`.
# https://github.com/terraform-docs/terraform-docs
if ! command -v terraform-docs &> /dev/null; then
  DOWNLOAD_URL=$(get-github-latest-release-url "terraform-docs/terraform-docs" "terraform-docs-v{version}-linux-amd64.tar.gz")
  install-binary-from-tar-url "$DOWNLOAD_URL" "terraform-docs"
fi

# Install Pulumi.
if ! command -v pulumi &> /dev/null; then
  curl --silent --fail --show-error --location https://get.pulumi.com | sh
  export PATH="$PATH:$HOME/.pulumi/bin"
fi

# Install Helm.
# https://helm.sh/docs/intro/install/
if ! command -v helm &> /dev/null; then
  curl --silent --fail --show-error --location https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm --yes
fi

# Install helmfmt.
# https://github.com/digitalstudium/helmfmt
if ! command -v helmfmt &> /dev/null; then
  curl --silent --fail --show-error --location https://github.com/digitalstudium/helmfmt/releases/latest/download/helmfmt_Linux_x86_64.tar.gz | sudo tar -xzf - -C /usr/local/bin/ helmfmt
fi

# --------------------------------
# Install quality of life software
# --------------------------------

# Install zoxide.
# https://github.com/ajeetdsouza/zoxide
if ! command -v zoxide &> /dev/null; then
  curl --silent --fail --show-error --location https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Install fzf.
# https://github.com/junegunn/fzf
if ! command -v fzf &> /dev/null; then
  DOWNLOAD_URL=$(get-github-latest-release-url "junegunn/fzf" "fzf-{version}-linux_amd64.tar.gz")
  install-binary-from-tar-url "$DOWNLOAD_URL" "fzf"
fi

# -------------
# Install tools
# -------------

# Install the GitHub CLI.
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian
if ! command -v gh &> /dev/null; then
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl --silent --fail --show-error --location https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo mkdir -p -m 755 /etc/apt/sources.list.d
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh -y
fi

# Set up browser integration for WSL.
# Creates a wrapper that forwards URLs to the Windows default browser via cmd.exe, which lets
# tools like az login open a browser instead of falling back to device code.
if [[ ! -f /usr/local/bin/wslopen ]]; then
  printf '#!/bin/bash\n/mnt/c/Windows/System32/cmd.exe /C start "" "$@" 2>/dev/null\n' \
    | sudo tee /usr/local/bin/wslopen > /dev/null
  sudo chmod +x /usr/local/bin/wslopen
fi
export BROWSER=wslopen
if ! grep --quiet 'BROWSER=wslopen' "$BASHRC_PATH"; then
  echo 'export BROWSER=wslopen' >> "$BASHRC_PATH"
fi

# Install the Azure CLI.
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?view=azure-cli-latest&pivots=apt#option-1-install-with-one-command
if ! command -v az &> /dev/null; then
  curl --silent --fail --show-error --location https://aka.ms/InstallAzureCLIDeb | sudo bash
else
  az upgrade --yes
fi

# Inject the LogixHealth cert into the Azure CLI's Python certifi bundle so that `az` works inside
# the corporate network without SSL errors.
CERTIFI_PATH="/opt/az/lib/python3.13/site-packages/certifi/cacert.pem"
if [[ -s "$CERTIFI_PATH" ]]; then
  export REQUESTS_CA_BUNDLE="$CERTIFI_PATH"
  CERTIFICATE_NAME="BEDROOTCA001"
  if ! grep --quiet "$CERTIFICATE_NAME" "$CERTIFI_PATH"; then
    {
      echo
      echo "# $CERTIFICATE_NAME"
      curl --silent --fail --show-error --location "https://raw.githubusercontent.com/$GITHUB_USERNAME/configs/refs/heads/main/certs/$CERTIFICATE_NAME.crt"
    } | sudo tee -a "$CERTIFI_PATH" > /dev/null
  fi
fi

echo -e "\nSuccessfully set up WSL."
