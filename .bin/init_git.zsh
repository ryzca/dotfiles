#!/bin/zsh

cd ${HOME}
print -P "%F{117}%B==> Backing up git configs%b%f"

setopt nonomatch
set +e
mv -fv .git* "${BACKUP_DIR}" 2> /dev/null
mv -fv ${XDG_CONFIG_HOME}/git/config.local "${BACKUP_DIR}" 2> /dev/null
mv -fv ${XDG_CONFIG_HOME}/git "${BACKUP_DIR}" 2> /dev/null
set -e

print -P "\n%F{117}%B==> Creating symlink for git config%b%f"
ln -fnsv "${DOTFILES_CONFIGS}/git" "${XDG_CONFIG_HOME}/git"

print -P "\n%F{117}%B==> Initial setup for git%b%f"
() {
  git config --global --includes --get user.name > /dev/null && \
    print -P "%F{216}User config is already defined.%f" && exit 0

  echo -n "User config is not set. Create the initial config? [Yn]: "; read YN
  if [[ $YN == [nN] ]]; then
    print -P "%F{216}Cancelled the initial setup. Please manually configure. Refer to ${XDG_CONFIG_HOME}/git%f"
    exit 0
  fi

  print -P "%F{75}=> Creating config.local. Refer to ${XDG_CONFIG_HOME}/git%f"
  cp -pfv "${DOTFILES_CONFIGS}/git/config.local.sample" "${CONFIG_PATH_GIT:="${DOTFILES_CONFIGS}/git/config.local"}"
  print -P "%F{75}=> Current user.name/user.email are as follows.
   (Refer to "${CONFIG_PATH_GIT}")
     user.name: $(git config --global --includes --get user.name)
     user.email: $(git config --global --includes --get user.email)%f"
  echo -n "Make any changes? [Yn]: "; read YN
  [[ $YN == [nN] ]] && exit 0

  echo -n "Enter new user.name (blank to keep current value): "; read NEW_VALUE
  [[ -n "${NEW_VALUE}" ]] && git config --file "${CONFIG_PATH_GIT}" user.name "${NEW_VALUE}"
  echo -n "Enter new user.email (blank to keep current value): "; read NEW_VALUE
  [[ -n "${NEW_VALUE}" ]] && git config --file "${CONFIG_PATH_GIT}" user.email "${NEW_VALUE}"
  print -P "%F{75}=> Current user.name/user.email are as follows.
   (Refer to "${CONFIG_PATH_GIT}")
    user.name: $(git config --global --includes --get user.name)
    user.email: $(git config --global --includes --get user.email)%f"
}

unsetopt nonomatch
