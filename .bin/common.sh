#!/bin/bash

DOTFILES_HOME="$(cd "$(dirname "$0")"/.. && pwd)"
DOTFILES_CONFIGS="${DOTFILES_HOME}/configs"

source "${DOTFILES_CONFIGS}/zsh/.zshenv"
