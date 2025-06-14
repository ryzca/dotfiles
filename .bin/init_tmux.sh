#!/bin/bash

set -eu
source "$(cd $(dirname $0); pwd)/common.sh"
cd ${HOME}

log "==> Backing up tmux configs" "notice"
backup .tmux*
backup "${XDG_CONFIG_HOME}/tmux"

log "==> Creating symlink for tmux config" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/tmux" "${XDG_CONFIG_HOME}/tmux"

log "==> tmux setup completed" "notice"