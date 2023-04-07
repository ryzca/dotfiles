#!/bin/zsh

cd ${HOME}
log "==> Backing up git configs" "notice"

setopt nonomatch
set +e
mv -fv .git* "${BACKUP_DIR}" 2> /dev/null
mv -fv ${XDG_CONFIG_HOME}/git/config.local "${BACKUP_DIR}" 2> /dev/null
mv -fv ${XDG_CONFIG_HOME}/git "${BACKUP_DIR}" 2> /dev/null
set -e
unsetopt nonomatch

log "==> Creating symlink for git config" "notice"
ln -fnsv "${DOTFILES_CONFIGS}/git" "${XDG_CONFIG_HOME}/git"

log "==> Initial setup for git" "notice"
() {
  git config --global --includes --get user.name > /dev/null && \
    log "User config is already defined." "warn" && exit 0

  echo -n "User config is not set. Create the initial config? [Yn]: "; read YN
  echo "$YN" >> "${LOG_FILE}"
  if [[ $YN == [nN] ]]; then
    log "Cancelled the initial setup. Please manually configure. Refer to ${XDG_CONFIG_HOME}/git" "warn"
    exit 0
  fi

  log "=> Creating \"config.local\". Refer to ${XDG_CONFIG_HOME}/git" "info"
  cp -pfv "${DOTFILES_CONFIGS}/git/config.local.sample" "${CONFIG_PATH_GIT:="${DOTFILES_CONFIGS}/git/config.local"}"
  log "=> Current user.name/user.email are as follows.
   (Refer to "${CONFIG_PATH_GIT}")
     user.name: $(git config --global --includes --get user.name)
     user.email: $(git config --global --includes --get user.email)" "info"
  echo -n "Make any changes? [Yn]: "; read YN
  echo "$YN" >> "${LOG_FILE}"
  [[ $YN == [nN] ]] && exit 0

  echo -n "Enter new user.name (blank to keep current value): "; read NEW_VALUE
  echo "${NEW_VALUE}" >> "${LOG_FILE}"
  [[ -n "${NEW_VALUE}" ]] && git config --file "${CONFIG_PATH_GIT}" user.name "${NEW_VALUE}"
  echo -n "Enter new user.email (blank to keep current value): "; read NEW_VALUE
  echo "${NEW_VALUE}" >> "${LOG_FILE}"
  [[ -n "${NEW_VALUE}" ]] && git config --file "${CONFIG_PATH_GIT}" user.email "${NEW_VALUE}"
  log "=> Current user.name/user.email are as follows.
   (Refer to "${CONFIG_PATH_GIT}")
    user.name: $(git config --global --includes --get user.name)
    user.email: $(git config --global --includes --get user.email)" "info"
}
