#!/bin/bash

get_model_color() {
  case "$1" in
    *Opus*) echo 172 ;; # orange
    *Sonnet*) echo 111 ;; # blue
    *) echo 246 ;; # gray
  esac
}

get_percent_color() {
  local percent="$1"
  if ((percent >= 90)); then echo 167  # red
  elif ((percent >= 60)); then echo 142  # yellow
  else echo 70  # green
  fi
}

main() {
  local input model_name used_pct model_color percent_color

  input=$(cat)
  model_name=$(jq -r '.model.display_name' <<< "$input")
  used_pct=$(jq -r '.context_window.used_percentage // 0' <<< "$input")

  percent_color=$(get_percent_color "$used_pct")
  model_color=$(get_model_color "$model_name")

  printf "\033[0m\033[38;5;%dm󰚩 %s\033[0m \033[38;5;%dm %s%%\033[0m\n" \
    "$model_color" "$model_name" "$percent_color" "$used_pct"
}

main
