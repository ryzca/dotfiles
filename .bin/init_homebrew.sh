#!/bin/bash

set -eu
source "$(cd $(dirname $0); pwd)/common.sh"
cd ${HOME}

if [ "$(uname)" != "Darwin" ]; then
  log "Aborted. Homebrew installation is only for macOS." "error"
  exit 1
fi

if type brew &> /dev/null; then
  log "Homebrew is already installed." "info"
else
  log "==> Installing Homebrew" "notice"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  source "${DOTFILES_CONFIGS}/zsh/.zprofile"
fi

log "==> Updating Homebrew" "notice"
brew update

if xcode-select --print-path &> /dev/null; then
  log "Command Line Tools are already installed.", "info"
else
  log "==> Installing Command Line Tools" "notice"
  xcode-select --install
fi

log "==> Installing Homebrew apps (formula & cask)" "notice"
brew bundle install --file=${DOTFILES_CONFIGS}/homebrew/Brewfile --verbose --no-lock
