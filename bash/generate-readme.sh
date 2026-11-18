#!/bin/bash

# Regenerates "bash/README.md" with a reference of every alias/command available in the shell,
# pulled from Jeenil/configs (the shared base) plus the personal additions in this repo.
#
# Usage:
#   ./generate-readme.sh
#
# Re-run this any time configs/bash/commands/*.sh or bashrc_local.sh change and you want the docs
# to catch up.

set -euo pipefail # Exit on errors and undefined variables.

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
CONFIGS_REPO_PATH="${CONFIGS_REPO_PATH:-$HOME/repositories/configs}"

if [[ ! -d "$CONFIGS_REPO_PATH/bash/commands" ]]; then
  echo "Error: Could not find \"$CONFIGS_REPO_PATH/bash/commands\". Set CONFIGS_REPO_PATH to your configs repo clone." >&2
  exit 1
fi

python3 "$DIR/generate-readme.py" "$CONFIGS_REPO_PATH" "$DIR"
