#!/bin/zsh

DOTFILES_DIR="$(cd $(dirname $0); cd ..; pwd)"
RUN_DATE=$(date '+%Y%m%d_%H%M%S')

source "${DOTFILES_DIR}/configs/zsh/.zshenv"

print -P "%F{117}==> Backing up zsh profiles%f"
cd ${HOME}
mkdir -p "${BACKUP_DIR_ZSH:="${XDG_CONFIG_HOME}/.zsh.bak.${RUN_DATE}"}" && \
  mv -fv zshmv .zlogin .zlogout .zprofile .zshenv .zshrc .zsh_history .zsh_sessions .zprezto .zpreztorc "${BACKUP_DIR_ZSH}" 2> /dev/null

print -P "%F{117}==> Creating symlink for .zshenv%f"
ln -fnsv "${DOTFILES_DIR}/configs/zsh/.zshenv" "${HOME}/.zshenv"

print -P "%F{117}==> Creating symlink for ZDOTDIR%f"
ln -fnsv "${DOTFILES_DIR}/configs/zsh" "${ZDOTDIR}"
