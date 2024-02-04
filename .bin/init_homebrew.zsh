#!/bin/zsh

if [ "$(uname)" != "Darwin" ]; then
  log "Aborted. Homebrew installation is only for macOS." "error"
  exit 1
fi

if type brew >/dev/null; then
  log "Homebrew is already installed." "info"
else
  log "==> Installing Homebrew" "notice"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

log "==> Updating Homebrew" "notice"
brew update

log "==> Installing Homebrew apps (formula & cask)" "notice"
brew bundle install --file=${DOTFILES_CONFIGS}/homebrew/Brewfile --verbose --no-lock
