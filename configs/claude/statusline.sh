#!/bin/bash

readonly COMPACTION_THRESHOLD=160000

get_model_color() {
  case "$1" in
    *Opus*) echo 172 ;; # orange
    *Sonnet*) echo 111 ;; # blue
    *) echo 246 ;; # gray
  esac
}

get_percent_color() {
  local percent="$1"
  ((percent >= 90)) && echo 167 || \
  ((percent >= 60)) && echo 142 || \
  echo 108 # red yellow green
}

get_tokens() {
  local path="$1"
  [[ -f "$path" ]] || return

  tail -n 100 "$path" 2>/dev/null | \
  jq -rs '
    map(select(.type == "assistant" and .message.usage)) |
    last.message.usage // {} |
    ((.input_tokens // 0) +
     (.output_tokens // 0) +
     (.cache_creation_input_tokens // 0) +
     (.cache_read_input_tokens // 0))
  ' 2>/dev/null || echo 0
}

main() {
  local input model_name transcript tokens percent model_color token_fmt percent_color

  input=$(cat)
  model_name=$(jq -r '.model.display_name' <<< "$input")
  transcript=$(jq -r '.transcript_path' <<< "$input")

  tokens=$(get_tokens "$transcript")
  percent=$((tokens * 100 / COMPACTION_THRESHOLD))

  if ((tokens >= 1000)); then
    token_fmt="$(awk "BEGIN{printf \"%.1fK\", $tokens/1000}")"
  else
    token_fmt="${tokens:-_}"
  fi

  percent_color=$(get_percent_color "$percent")
  model_color=$(get_model_color "$model_name")

  printf "\033[0m\033[38;5;%dm󰚩 %s\033[0m \033[38;5;%dm %s (%d%%)\033[0m\n" \
    "$model_color" "$model_name" "$percent_color" "$token_fmt" "$percent"
}

main
