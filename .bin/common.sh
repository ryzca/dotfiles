#!/bin/bash

export DOTFILES_HOME="$(cd "$(dirname "$0")"/.. && pwd)"
export DOTFILES_CONFIGS="${DOTFILES_HOME}/configs"

source "${DOTFILES_CONFIGS}/zsh/.zshenv"

export ZSH_COMPlETIONS_DIR="${XDG_DATA_HOME}/zsh/completions"

log() {
  local msg="$1"
  local level="${2:-}"
  local prefix=""
  local suffix=$'\e[0m'
  local formatted_msg=""

  case "${level}" in
    notice)
      prefix=$'\e[96m'
      formatted_msg="$msg"
      ;;
    info)
      prefix=$'\e[92m'
      formatted_msg="[INFO] $msg"
      ;;
    warn)
      prefix=$'\e[93m'
      formatted_msg="[WARN] $msg"
      ;;
    error)
      prefix=$'\e[91m'
      formatted_msg="[ERROR] $msg"
      ;;
    *)
      prefix=$'\e[97m'
      formatted_msg="$msg"
      ;;
  esac

  if [[ "${level}" == "warn" ]] || [[ "${level}" == "error" ]]; then
    echo -e "${prefix}${formatted_msg}${suffix}" 1>&2
  else
    echo -e "${prefix}${formatted_msg}${suffix}"
  fi
}

backup() {
  local has_files_to_backup=false

  if [[ ! -d "${BACKUP_DIR}" ]]; then
    log "Backup directory does not exist." "error"
    exit 1
  fi

  for path in "$@"; do
    if [[ -e "$path" ]]; then
      has_files_to_backup=true
      mv -fv "$path" "${BACKUP_DIR}" 2> /dev/null
    fi
  done

  if [[ $has_files_to_backup == false ]]; then
    echo -e $'\e[90m'No files to backup.$'\e[0m'
  fi
}
