#!/bin/bash

set -u

: $1 $2

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/common.sh"
RUN_TARGET="$1"
RUN_DATETIME="$2"
BACKUP_DIR_BASE="${DOTFILES_HOME}/.bak/${RUN_DATETIME}"
BACKUP_DIR="${BACKUP_DIR_BASE}/${RUN_TARGET}"

mkdir -p "${BACKUP_DIR}"
LOG_FILE="${BACKUP_DIR_BASE}/init.log"

log() {
  local msg="$1"
  local level="${2:-}"
  local log_to_file="${3:-true}"
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

  if [[ -n ${log_to_file} && -n ${LOG_FILE} ]]; then
    echo "${formatted_msg}" >> "${LOG_FILE}"
    echo -e "${prefix}${formatted_msg}${suffix}"
  else
    echo -e "${prefix}${formatted_msg}${suffix}"
  fi
}

backup() {
  local has_files_to_backup=false

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

log "-------------------------"
log "Starting ${RUN_TARGET} setup" "info"
source "${SCRIPT_DIR}"/init_$1.sh
exit_code=$?
log ""
if [[ "${exit_code}" == 0 ]]; then
  log "Finished! ${RUN_TARGET} setup completed." "info"
else
  log "Please check the error message and try again." "error"
fi
log "Log file has been output to ${LOG_FILE}"
