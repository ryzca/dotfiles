#!/bin/zsh

if ! mise version 2> /dev/null; then
  log "Aborted. mise is not installed." "error"
  exit 1
fi

cd ${HOME}

# # Node.js
log "==> Node.js: Backing up related files" "notice"
backup .npm .npmrc
log "==> Node.js: Creating config symlink" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/npm" "${XDG_CONFIG_HOME}/npm"
