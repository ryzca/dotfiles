#!/bin/bash

set -eu

: $1 $2

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/common.sh"

RUN_TARGET="$1"
RUN_DATETIME="$2"
BACKUP_DIR_BASE="${DOTFILES_HOME}/.bak/${RUN_DATETIME}"
export BACKUP_DIR="${BACKUP_DIR_BASE}/${RUN_TARGET}"

mkdir -p "${BACKUP_DIR}"
LOG_FILE="${BACKUP_DIR_BASE}/init.log"

{
  log "-------------------------"
  log "Starting ${RUN_TARGET} setup" "info"
  bash "${SCRIPT_DIR}/init_$1.sh" 2>&1
  exit_code="${PIPESTATUS[0]}"
  log ""
  if [[ "${exit_code}" == 0 ]]; then
    log "Finished! ${RUN_TARGET} setup completed." "info"
  else
    log "Please check the error message and try again." "error"
  fi
} | tee -a "${LOG_FILE}"

sed 's/\x1b\[[0-9;]*m//g' "${LOG_FILE}" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "${LOG_FILE}"
log "Log file has been output to ${LOG_FILE}"
