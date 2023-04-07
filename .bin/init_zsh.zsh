#!/bin/zsh

cd ${HOME}
log "==> Backing up zsh profiles" "notice"

set +e
mv -fv zshmv .zlogin .zlogout .zprofile .zshenv .zshrc .zsh_history .zsh_sessions .zprezto .zpreztorc "${BACKUP_DIR}" 2> /dev/null
mv -fv "${XDG_CONFIG_HOME}/zsh" "${BACKUP_DIR}" 2> /dev/null
set -e

log "==> Creating symlink for .zshenv" "notice"
ln -fnsv "${ZDOTDIR}/.zshenv" "${HOME}/.zshenv"

log "==> Creating symlink for ZDOTDIR" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/zsh" "${ZDOTDIR}"
