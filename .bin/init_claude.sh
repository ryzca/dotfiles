#!/bin/bash

set -eu
source "$(cd $(dirname $0); pwd)/common.sh"
cd ${HOME}

log "==> Backing up claude configs" "notice"
backup .claude/CLAUDE.md
backup .claude/settings.json

log "==> Creating .claude directory" "notice"
mkdir -p "${HOME}/.claude"

log "==> Creating symlinks for claude configs" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
ln -fnsv "${DOTFILES_CONFIGS}/claude/settings.json" "${HOME}/.claude/settings.json"

log "==> Claude configuration completed" "notice"