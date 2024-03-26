#!/bin/bash

set -eu
source "$(cd $(dirname $0); pwd)/common.sh"
cd ${HOME}

log "==> Create dev directory" "notice"
mkdir -vp "${HOME}/dev/_arch"
mkdir -vp "${HOME}/dev/res/configs"
mkdir -vp "${HOME}/dev/res/docs"
mkdir -vp "${HOME}/dev/res/libs"
mkdir -vp "${HOME}/dev/res/scripts"

log "==> Backing up SQLite history" "notice"
backup .sqlite_history
log "==> Backing up MySQL history" "notice"
backup .mysql_history
log "==> Backing up psql history" "notice"
backup .psql_history

log "==> Backing up bat profiles" "notice"
backup "${XDG_CONFIG_HOME}/bat"

log "==> Creating symlink for bat config" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/bat" "${XDG_CONFIG_HOME}/bat"
