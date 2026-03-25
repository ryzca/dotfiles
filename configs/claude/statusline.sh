#!/bin/bash

get_model_color() {
  case "$1" in
    *Opus*) echo 172 ;; # orange
    *Sonnet*) echo 111 ;; # blue
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

format_countdown() {
  local reset_at="$1"
  [[ -z "$reset_at" || "$reset_at" == "null" ]] && return

  local now remaining days hours mins
  now=$(date +%s)
  remaining=$((reset_at - now))

  if ((remaining <= 0)); then
    echo "0m"
    return
  fi

  days=$((remaining / 86400))
  hours=$(( (remaining % 86400) / 3600 ))
  mins=$(( (remaining % 3600) / 60 ))

  if ((days > 0)); then
    echo "${days}d${hours}h"
  elif ((hours > 0)); then
    echo "${hours}h${mins}m"
  else
    echo "${mins}m"
  fi
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

    printf "\033[0m\033[38;5;%dm󰚩 %s\033[0m \033[38;5;%dm %s%%\033[0m \033[38;5;%dm󰔛 %s%%\033[38;5;243m ↺\033[38;5;246m%s\033[0m \033[38;5;%dm󰃭 %s%%\033[38;5;243m ↺\033[38;5;246m%s\033[0m\n" \
      "$model_color" "$model_name" "$percent_color" "$used_pct" \
      "$five_color" "$five_pct" "$five_cd" \
      "$seven_color" "$seven_pct" "$seven_cd"
  else
    printf "\033[0m\033[38;5;%dm󰚩 %s\033[0m \033[38;5;%dm %s%%\033[0m\n" \
      "$model_color" "$model_name" "$percent_color" "$used_pct"
  fi

  # Line 2: branch & changes
  if [[ -n "$branch" ]]; then
    printf "\033[38;5;246m %s\033[0m \033[38;5;246m \033[38;5;70m+%s\033[0m \033[38;5;167m-%s\033[0m\n" \
      "$branch" "$lines_added" "$lines_removed"
  fi
}

main
