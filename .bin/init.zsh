#!/bin/zsh

set -eu

: $1 $2

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
RUN_TARGET="$1"
RUN_DATETIME="$2"
source "${SCRIPT_DIR}/common.zsh"
BACKUP_DIR_BASE="${XDG_CONFIG_HOME}/.bak/${RUN_DATETIME}"
BACKUP_DIR="${BACKUP_DIR_BASE}/${RUN_TARGET}"

mkdir -p "${BACKUP_DIR}"
LOG_FILE="${BACKUP_DIR_BASE}/init.log"

echo "-------------------------" | tee -a "${LOG_FILE}"
print -P "%F{112}Starting ${RUN_TARGET} setup.%f" | tee -a "${LOG_FILE}"
{{ source "${SCRIPT_DIR}/init_$1.zsh" | tee -a "${LOG_FILE}"; } 3>&2 2>&1 1>&3 } | tee -a "${LOG_FILE}" 3>&2 2>&1 1>&3
print -P "%F{112}Finished! Log file has been output to ${LOG_FILE}%f" | tee -a "${LOG_FILE}"
