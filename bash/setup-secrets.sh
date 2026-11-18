#!/bin/bash

# Creates or updates the private secrets repo with age-encrypted credentials.
# Run this once to set things up, and re-run whenever ~/.env or SSH keys change.
#
# Prerequisites:
#   1. A private GitHub repo named "secrets" cloned at ~/repositories/secrets
#      Create it: gh repo create secrets --private --clone
#      Then move it: mv secrets ~/repositories/
#   2. Your SSH ed25519 key at ~/.ssh/id_ed25519
#   3. age installed: sudo apt-get install age

set -euo pipefail

SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_PUB_KEY="$HOME/.ssh/id_ed25519.pub"
SECRETS_DIR="$HOME/repositories/secrets"

# Validate prerequisites.
if ! command -v age &> /dev/null; then
  echo "Error: age is required. Install with: sudo apt-get install age" >&2
  exit 1
fi

if [[ ! -s "$SSH_KEY" ]]; then
  echo "Error: SSH private key not found at $SSH_KEY" >&2
  exit 1
fi

if [[ ! -s "$SSH_PUB_KEY" ]]; then
  echo "Error: SSH public key not found at $SSH_PUB_KEY" >&2
  exit 1
fi

if [[ ! -d "$SECRETS_DIR" ]]; then
  echo "Error: secrets repo not found at $SECRETS_DIR" >&2
  echo "Create it first:" >&2
  echo "  gh repo create secrets --private" >&2
  echo "  git clone git@github.com:\$(gh api user --jq .login)/secrets.git ~/repositories/secrets" >&2
  exit 1
fi

RECIPIENT="$(cat "$SSH_PUB_KEY")"

# Encrypt ~/.env
if [[ -s "$HOME/.env" ]]; then
  age --encrypt --recipient "$RECIPIENT" --output "$SECRETS_DIR/.env.age" "$HOME/.env"
  echo "Encrypted ~/.env -> secrets/.env.age"
else
  echo "Warning: ~/.env not found or empty - skipping."
fi

# Encrypt work SSH private key.
if [[ -s "$HOME/.ssh/work/id_rsa" ]]; then
  age --encrypt --recipient "$RECIPIENT" --output "$SECRETS_DIR/id_rsa.age" "$HOME/.ssh/work/id_rsa"
  echo "Encrypted ~/.ssh/work/id_rsa -> secrets/id_rsa.age"
else
  echo "Warning: ~/.ssh/work/id_rsa not found or empty - skipping."
fi

# Commit and push if anything changed.
if ! git -C "$SECRETS_DIR" diff --quiet || [[ -n "$(git -C "$SECRETS_DIR" ls-files --others --exclude-standard)" ]]; then
  git -C "$SECRETS_DIR" add .
  git -C "$SECRETS_DIR" commit --message "chore: update secrets"
  git -C "$SECRETS_DIR" push
  echo -e "\nSecrets backed up successfully."
else
  echo -e "\nNo changes - secrets are already up to date."
fi
