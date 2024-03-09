#!/bin/bash

cd ${HOME}

log "==> Backing up zsh profiles" "notice"
backup zshmv .zlogin .zlogout .zprofile .zshenv .zshrc .zsh_history .zsh_sessions .zprezto .zpreztorc .zcompdump
backup "${XDG_CONFIG_HOME}/zsh"

log "==> Creating symlink for .zshenv" "notice"
ln -fnsv "${ZDOTDIR}/.zshenv" "${HOME}/.zshenv"

log "==> Creating symlink for ZDOTDIR" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/zsh" "${ZDOTDIR}"

log "==> Creating zsh directory" "notice"
mkdir -vp "${XDG_DATA_HOME}/zsh/completions"

log "==> Installing Zinit" "notice"
if [ -d "${XDG_DATA_HOME}/zinit/bin" ]; then
    log "Aborted. Zinit repository already exists." "warn"
    # git -C "${XDG_DATA_HOME}/zinit/bin" pull
else
    git clone -b "v3.10.0" "https://github.com/zdharma-continuum/zinit" "${XDG_DATA_HOME}/zinit/bin"
fi
