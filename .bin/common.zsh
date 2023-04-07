#!/bin/zsh

DOTFILES_HOME="$(cd $(dirname $0); cd -; pwd)"
DOTFILES_CONFIGS="${DOTFILES_HOME}/configs"

source "${DOTFILES_CONFIGS}/zsh/.zshenv"
