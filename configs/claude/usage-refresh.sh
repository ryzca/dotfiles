#!/bin/bash

# .claude.json の cachedUsageUtilization は /usage を開いたときしか更新されない。
# headless の /usage で CLI に取得させる。ローカルコマンドなのでモデル呼び出しはない。
set -u

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.config/claude}"
WORK_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-usage-refresh"
LOCK_DIR="$WORK_DIR/.lock"
STAMP_FILE="$WORK_DIR/.last-run"
SESSION_MAX_AGE_MIN=60

# 複数セッションの statusline から同時に呼ばれる。取り残しは2分で解除する
acquire_lock() {
  find "$LOCK_DIR" -maxdepth 0 -mmin +2 -exec rmdir {} \; 2>/dev/null
  mkdir "$LOCK_DIR" 2>/dev/null
}

prune_sessions() {
  local dir
  for dir in "$CONFIG_DIR"/projects/*claude-usage-refresh; do
    [[ -d "$dir" ]] || continue
    find "$dir" -type f -mmin "+$SESSION_MAX_AGE_MIN" -delete 2>/dev/null
  done
}

main() {
  mkdir -p "$WORK_DIR" || exit 0
  acquire_lock || exit 0
  trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

  # 取得の成否によらず呼び出し間隔を守らせる
  touch "$STAMP_FILE" 2>/dev/null

  # 使い捨てセッションのログを実プロジェクトの履歴に混ぜない
  cd "$WORK_DIR" || exit 0

  # herdr のフックがペイン名や状態を書き換えないよう環境を落とす
  env -u HERDR_ENV -u HERDR_PANE_ID -u HERDR_SOCKET_PATH \
    claude -p "/usage" --output-format json >/dev/null 2>&1

  prune_sessions
}

main
