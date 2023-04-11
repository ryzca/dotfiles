#!/bin/zsh

set -eu

: $1 $2

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
RUN_TARGET="$1"
RUN_DATETIME="$2"
source "${SCRIPT_DIR}/common.zsh"
BACKUP_DIR_BASE="${XDG_CONFIG_HOME}/.dotfilesbak/${RUN_DATETIME}"
BACKUP_DIR="${BACKUP_DIR_BASE}/${RUN_TARGET}"

mkdir -p "${BACKUP_DIR}"
LOG_FILE="${BACKUP_DIR_BASE}/init.log"

log() {
  local MSG="$1"
  local LEVEL="${2:-""}"
  local LOG_TO_FILE="${3:-""}"
  local SUFFIX="%f"

  case "${LEVEL}" in
    notice)
      local PREFIX="%F{117}%B"
      SUFFIX="%b${SUFFIX}"
      ;;
    info)
      local PREFIX="%F{114}"
      ;;
    warn)
      local PREFIX="%F{220}"
      ;;
    error)
      local PREFIX="%F{202}"
      ;;
    *)
      local PREFIX="%F{252}"
      ;;
  esac

  if [[ ${LOG_TO_FILE} ]]; then
    print -P "${PREFIX}${MSG}${SUFFIX}" | tee -a "${LOG_FILE}"
  else
    print -P "${PREFIX}${MSG}${SUFFIX}"
  fi
}

log "-------------------------" "" true
log "Starting ${RUN_TARGET} setup" "info" true
log "" "" true
source "${SCRIPT_DIR}/init_$1.zsh" 2>&1 | tee -a "${LOG_FILE}"
EXIT_CODE="${pipestatus[1]}"
log "" "" true
if [[ "${EXIT_CODE}" == 0 ]]; then
  log "Finished! ${RUN_TARGET} setup completed." "info" true
else
  log "Please check the error message and try again." "error" true
fi
log "Log file has been output to ${LOG_FILE}" true
