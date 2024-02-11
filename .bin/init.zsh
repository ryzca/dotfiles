#!/bin/zsh

set -eu

: $1 $2

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
RUN_TARGET="$1"
RUN_DATETIME="$2"
source "${SCRIPT_DIR}/common.zsh"
BACKUP_DIR_BASE="${DOTFILES_HOME}/.bak/${RUN_DATETIME}"
BACKUP_DIR="${BACKUP_DIR_BASE}/${RUN_TARGET}"

mkdir -p "${BACKUP_DIR}"
LOG_FILE="${BACKUP_DIR_BASE}/init.log"

log() {
  local msg="$1"
  local level="${2:-""}"
  local log_to_file="${3:-""}"
  local suffix="%f"

  case "${level}" in
    notice)
      local prefix="%F{117}%B"
      suffix="%b${suffix}"
      ;;
    info)
      local prefix="%F{114}"
      ;;
    warn)
      local prefix="%F{220}"
      ;;
    error)
      local prefix="%F{202}"
      ;;
    *)
      local prefix="%F{252}"
      ;;
  esac

  if [[ ${log_to_file} ]]; then
    print -P "${prefix}${msg}${suffix}" | tee -a "${LOG_FILE}"
  else
    print -P "${prefix}${msg}${suffix}"
  fi
}

backup() {
  setopt nonomatch
  set +e
  mv -fv $@ "${BACKUP_DIR}" 2> /dev/null
  set -e
  unsetopt nonomatch
}

log "-------------------------" "" true
log "Starting ${RUN_TARGET} setup" "info" true
log "" "" true
source "${SCRIPT_DIR}/init_$1.zsh" 2>&1 | tee -a "${LOG_FILE}"
exit_code="${pipestatus[1]}"
log "" "" true
if [[ "${exit_code}" == 0 ]]; then
  log "Finished! ${RUN_TARGET} setup completed." "info" true
else
  log "Please check the error message and try again." "error" true
fi
log "Log file has been output to ${LOG_FILE}" true
