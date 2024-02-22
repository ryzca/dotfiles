#!/bin/bash

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
cd ${HOME}
log "==> Node.js: Backing up related files" "notice"
backup .npm .npmrc
log "==> Node.js: Creating config symlink" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/npm" "${XDG_CONFIG_HOME}/npm"

mise install
