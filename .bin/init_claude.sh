#!/bin/bash

set -eu
source "$(cd $(dirname $0); pwd)/common.sh"
cd ${HOME}

# XDG Base Directory compliance
CLAUDE_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/claude"

log "==> Backing up existing claude directory" "notice"
if [[ -e .config/claude && ! -L .config/claude ]]; then
  backup .config/claude
fi

log "==> Creating symlink for claude config directory" "notice"
# Remove existing symlink if it exists
if [[ -L "${CLAUDE_CONFIG_DIR}" ]]; then
  rm "${CLAUDE_CONFIG_DIR}"
fi

# Create parent directory if needed
mkdir -p "$(dirname "${CLAUDE_CONFIG_DIR}")"

# Create symlink to dotfiles claude directory
ln -fnsv "${DOTFILES_CONFIGS}/claude" "${CLAUDE_CONFIG_DIR}"

log "==> Claude configuration completed" "notice"
