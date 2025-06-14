#!/bin/bash

set -eu
source "$(cd $(dirname $0); pwd)/common.sh"
cd ${HOME}

log "==> Backing up ghostty configs" "notice"
backup "${XDG_CONFIG_HOME}/ghostty"

log "==> Creating symlink for ghostty config" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/ghostty" "${XDG_CONFIG_HOME}/ghostty"

log "==> ghostty setup completed" "notice"