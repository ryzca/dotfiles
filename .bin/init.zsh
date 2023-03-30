#!/bin/zsh

DOTFILES_DIR="$(cd $(dirname $0); cd ..; pwd)"
RUN_DATE=$(date '+%Y%m%d_%H%M%S')

source "${DOTFILES_DIR}/zsh/runcoms/.zshenv"

mkdir -p "${XDG_CONFIG_HOME:=$HOME}/zsh"

print -P "%F{117}==> Backing up zsh profiles%f"
cd ${HOME}
mkdir -p "${RUNCOMS_BACKUP_DIR:="${XDG_CONFIG_HOME}/zsh/.runcoms.bak.${RUN_DATE}"}" && \
  mv -fv zshmv .zlogin .zlogout .zprofile .zshenv .zshrc .zsh_history .zsh_sessions "${RUNCOMS_BACKUP_DIR}" 2> /dev/null

print -P "%F{117}==> Creating symlink for .zshenv%f"
ln -fnsv "${DOTFILES_DIR}/zsh/runcoms/.zshenv" "${HOME}/.zshenv"

print -P "%F{117}==> Creating symlink for runcoms and configs%f"
ln -fnsv "${DOTFILES_DIR}/zsh/runcoms" "${ZDOTDIR}" && \
ln -fnsv "${DOTFILES_DIR}/zsh/configs" "${XDG_CONFIG_HOME}/zsh/configs"
