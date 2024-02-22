#!/bin/bash

cd ${HOME}

log "==> Backing up vim configs" "notice"
backup .vim*
backup "${XDG_CONFIG_HOME}/vim"

log "==> Creating symlink for vim config" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/vim" "${XDG_CONFIG_HOME}/vim"

log "==> Installing Dein.vim" "notice"
DEIN_DIR="${XDG_DATA_HOME}/vim/dein/repos/github.com/Shougo/dein.vim"
if [[ -d "${DEIN_DIR}/.git" ]]; then
  log "Aborted. Dein.vim repository already exists." "warn"
  log "Refer to ${DEIN_DIR}"
else
  mkdir -p "${DEIN_DIR}"
  git clone https://github.com/Shougo/dein.vim "${DEIN_DIR}"
fi
