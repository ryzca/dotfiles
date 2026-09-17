#!/bin/bash

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.config/claude}"
CLAUDE_JSON="$CONFIG_DIR/.claude.json"
USAGE_REFRESH="$CONFIG_DIR/usage-refresh.sh"
USAGE_REFRESH_STAMP="${XDG_CACHE_HOME:-$HOME/.cache}/claude-usage-refresh/.last-run"
USAGE_REFRESH_INTERVAL=300
# CLI 自身がキャッシュを無効とみなす経過時間に合わせる
FABLE_CACHE_TTL=3600
# 定期更新が効いていれば自明なので、遅れたときだけ経過時間を出す
FABLE_STALE_AFTER=600

# レア度順 (gray < green < blue < purple < gold) をモデルのティアに対応させる
get_model_color() {
  case "$1" in
    *Fable* | *Mythos*) echo 214 ;; # gold
    *Opus*) echo 135 ;; # purple
    *Sonnet*) echo 111 ;; # blue
    *Haiku*) echo 114 ;; # green
    *) echo 246 ;; # gray
  esac
}

get_context_color() {
  local pct="$1"
  if ((pct >= 90)); then echo 167    # red
  elif ((pct >= 60)); then echo 142  # yellow
  else echo 70                       # green
  fi
}

get_5h_color() {
  local pct="$1"
  if ((pct >= 90)); then echo 167    # red
  elif ((pct >= 60)); then echo 142  # yellow
  else echo 73                       # cyan
  fi
}

get_7d_color() {
  local pct="$1"
  if ((pct >= 90)); then echo 167    # red
  elif ((pct >= 60)); then echo 142  # yellow
  else echo 139                      # purple
  fi
}

get_fable_color() {
  local pct="$1"
  if ((pct >= 90)); then echo 167    # red
  elif ((pct >= 60)); then echo 142  # yellow
  else echo 214                      # gold
  fi
}

format_duration() {
  local secs="$1" days hours mins

  if ((secs <= 0)); then
    echo "0m"
    return
  fi

  days=$((secs / 86400))
  hours=$(( (secs % 86400) / 3600 ))
  mins=$(( (secs % 3600) / 60 ))

  if ((days > 0)); then
    echo "${days}d${hours}h"
  elif ((hours > 0)); then
    echo "${hours}h${mins}m"
  else
    echo "${mins}m"
  fi
}

format_countdown() {
  local reset_at="$1"
  [[ -z "$reset_at" || "$reset_at" == "null" || "$reset_at" == "0" ]] && return

  format_duration $(( reset_at - $(date +%s) ))
}

# Fable の週次枠は statusline の stdin に来ないので CLI のキャッシュから読む
read_usage_cache() {
  [[ -r "$CLAUDE_JSON" ]] || return
  jq -c '.cachedUsageUtilization // empty' "$CLAUDE_JSON" 2>/dev/null
}

# ヘッダ由来の 5h/7d と違い最新とは限らないので、取得からの経過秒も返す
read_fable_usage() {
  local cache="$1" fetched_ms age
  [[ -n "$cache" ]] || return

  fetched_ms=$(jq -r '.fetchedAtMs // empty' <<< "$cache")
  [[ -n "$fetched_ms" ]] || return
  age=$(( $(date +%s) - fetched_ms / 1000 ))
  ((age < 0 || age > FABLE_CACHE_TTL)) && return

  jq -r --argjson age "$age" '
    first(.utilization.limits[]?
          | select(.kind == "weekly_scoped"
                   and (.scope.model.display_name // "" | startswith("Fable"))))
    | [.percent, $age,
       (.resets_at // ""
        | try (sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601) catch 0)]
    | @tsv' <<< "$cache"
}

# 描画は止めずに裏で更新させる。空振りしても叩き続けないよう前回実行時刻で判定する
trigger_usage_refresh() {
  local last

  [[ -x "$USAGE_REFRESH" ]] || return
  last=$(stat -f %m "$USAGE_REFRESH_STAMP" 2>/dev/null || echo 0)
  (( $(date +%s) - last < USAGE_REFRESH_INTERVAL )) && return

  "$USAGE_REFRESH" </dev/null >/dev/null 2>&1 &
}

build_fable_segment() {
  local pct age reset_at countdown
  read -r pct age reset_at <<< "$(read_fable_usage "$1")"
  [[ -n "$pct" ]] || return

  countdown=$(format_countdown "$reset_at")
  printf " \033[38;5;%dm󰆥 %s%%\033[0m" "$(get_fable_color "$pct")" "$pct"
  [[ -n "$countdown" ]] \
    && printf "\033[38;5;243m ↺\033[38;5;246m%s\033[0m" "$countdown"
  ((age >= FABLE_STALE_AFTER)) \
    && printf "\033[38;5;243m ·\033[38;5;246m%s\033[0m" "$(format_duration "$age")"
}

main() {
  local input model_name used_pct model_color percent_color

  input=$(cat)
  model_name=$(jq -r '.model.display_name' <<< "$input")
  used_pct=$(jq -r '.context_window.used_percentage // 0' <<< "$input")

  # Git & changes
  local cwd branch lines_added lines_removed
  cwd=$(jq -r '.cwd // empty' <<< "$input")
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  lines_added=$(jq -r '.cost.total_lines_added // 0' <<< "$input")
  lines_removed=$(jq -r '.cost.total_lines_removed // 0' <<< "$input")

  percent_color=$(get_context_color "$used_pct")
  model_color=$(get_model_color "$model_name")

  trigger_usage_refresh

  local fable_seg
  fable_seg=$(build_fable_segment "$(read_usage_cache)")

  # Rate limit (from stdin JSON)
  local five_pct seven_pct five_color seven_color five_reset seven_reset five_cd seven_cd
  five_pct=$(jq -r '.rate_limits.five_hour.used_percentage // empty | floor' <<< "$input" 2>/dev/null)
  seven_pct=$(jq -r '.rate_limits.seven_day.used_percentage // empty | floor' <<< "$input" 2>/dev/null)

  if [[ -n "$five_pct" ]]; then
    five_reset=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<< "$input" 2>/dev/null)
    seven_reset=$(jq -r '.rate_limits.seven_day.resets_at // empty' <<< "$input" 2>/dev/null)
    five_cd=$(format_countdown "$five_reset")
    seven_cd=$(format_countdown "$seven_reset")
    five_color=$(get_5h_color "$five_pct")
    seven_color=$(get_7d_color "$seven_pct")

    printf "\033[0m\033[38;5;%dm󰚩 %s\033[0m \033[38;5;%dm %s%%\033[0m \033[38;5;%dm󰔛 %s%%\033[38;5;243m ↺\033[38;5;246m%s\033[0m \033[38;5;%dm󰃭 %s%%\033[38;5;243m ↺\033[38;5;246m%s\033[0m%s\n" \
      "$model_color" "$model_name" "$percent_color" "$used_pct" \
      "$five_color" "$five_pct" "$five_cd" \
      "$seven_color" "$seven_pct" "$seven_cd" \
      "$fable_seg"
  else
    printf "\033[0m\033[38;5;%dm󰚩 %s\033[0m \033[38;5;%dm %s%%\033[0m%s\n" \
      "$model_color" "$model_name" "$percent_color" "$used_pct" "$fable_seg"
  fi

  # Line 2: branch & changes
  if [[ -n "$branch" ]]; then
    printf "\033[38;5;246m %s\033[0m \033[38;5;246m \033[38;5;70m+%s\033[0m \033[38;5;167m-%s\033[0m\n" \
      "$branch" "$lines_added" "$lines_removed"
  fi
}

main
