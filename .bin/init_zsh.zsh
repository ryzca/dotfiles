#!/bin/zsh

cd ${HOME}
log "==> Backing up zsh profiles" "notice"

set +e
mv -fv zshmv .zlogin .zlogout .zprofile .zshenv .zshrc .zsh_history .zsh_sessions .zprezto .zpreztorc .zcompdump "${BACKUP_DIR}" 2> /dev/null
mv -fv "${XDG_CONFIG_HOME}/zsh" "${BACKUP_DIR}" 2> /dev/null
set -e

log "==> Creating symlink for .zshenv" "notice"
ln -fnsv "${ZDOTDIR}/.zshenv" "${HOME}/.zshenv"

log "==> Creating symlink for ZDOTDIR" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/zsh" "${ZDOTDIR}"

log "==> Installing Zinit" "notice"
if [ -d "${XDG_DATA_HOME}/zinit/bin" ]; then
    log "Aborted. Zinit repository already exists." "warn"
    # git -C "${XDG_DATA_HOME}/zinit/bin" pull
else
    git clone -b "v3.10.0" "https://github.com/zdharma-continuum/zinit" "${XDG_DATA_HOME}/zinit/bin"
fi
