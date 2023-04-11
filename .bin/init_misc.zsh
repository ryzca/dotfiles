#!/bin/zsh

cd ${HOME}

setopt nonomatch
set +e
log "==> Backing up SQLite history" "notice"
mv -fv .sqlite_history "${BACKUP_DIR}" 2> /dev/null
log "==> Backing up MySQL history" "notice"
mv -fv .mysql_history "${BACKUP_DIR}" 2> /dev/null
log "==> Backing up psql history" "notice"
mv -fv .psql_history "${BACKUP_DIR}" 2> /dev/null
set -e
unsetopt nonomatch
