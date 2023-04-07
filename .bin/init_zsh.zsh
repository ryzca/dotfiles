#!/bin/zsh

cd ${HOME}
print -P "%F{117}%B==> Backing up zsh profiles%b%f"

set +e
mv -fv zshmv .zlogin .zlogout .zprofile .zshenv .zshrc .zsh_history .zsh_sessions .zprezto .zpreztorc "${BACKUP_DIR}" 2> /dev/null
mv -fv "${XDG_CONFIG_HOME}/zsh" "${BACKUP_DIR}" 2> /dev/null
set -e

print -P "\n%F{117}%B==> Creating symlink for .zshenv%b%f"
ln -fnsv "${ZDOTDIR}/.zshenv" "${HOME}/.zshenv"

print -P "\n%F{117}%B==> Creating symlink for ZDOTDIR%b%f"
ln -fnsv "${DOTFILES_CONFIGS}/zsh" "${ZDOTDIR}"
