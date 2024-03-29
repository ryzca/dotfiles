#!/bin/bash

set -eu
source "$(cd $(dirname $0); pwd)/common.sh"
cd ${HOME}

log "==> Checking mise" "notice"
if ! mise version 2> /dev/null; then
  log "Aborted. mise is not installed." "error"
  exit 1
fi

log "==> Backing up mise configs" "notice"
backup "${XDG_CONFIG_HOME}/mise"

log "==> Creating symlink for mise config" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/mise" "${XDG_CONFIG_HOME}/mise"

# Node.js
log "==> Node.js: Backing up related files" "notice"
backup .npm .npmrc
log "==> Node.js: Creating config symlink" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/npm" "${XDG_CONFIG_HOME}/npm"

# Python
# log "==> Python: Backing up related files" "notice"
# backup
log "==> Python: Creating config symlink" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/python" "${XDG_CONFIG_HOME}/python"

log "==> Installing modules from mise configs" "notice"
mise install
