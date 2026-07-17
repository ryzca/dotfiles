#!/bin/bash

set -eu
source "$(cd $(dirname $0); pwd)/common.sh"
cd ${HOME}

HERDR_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/herdr"

log "==> Backing up existing herdr directory" "notice"
if [[ -e "${HERDR_CONFIG_DIR}" && ! -L "${HERDR_CONFIG_DIR}" ]]; then
  backup "${HERDR_CONFIG_DIR}"
fi

log "==> Creating symlink for herdr config directory" "notice"
if [[ -L "${HERDR_CONFIG_DIR}" ]]; then
  rm "${HERDR_CONFIG_DIR}"
fi

mkdir -p "$(dirname "${HERDR_CONFIG_DIR}")"

ln -fnsv "${DOTFILES_CONFIGS}/herdr" "${HERDR_CONFIG_DIR}"

log "==> herdr setup completed" "notice"
