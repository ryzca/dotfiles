#!/bin/bash

readonly CACHE_FILE="/tmp/claude-usage-cache.json"
readonly CACHE_TTL=360

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
  local now epoch remaining days hours mins

  now=$(date +%s)
  epoch=$(date -juf "%Y-%m-%dT%H:%M:%S" "${reset_at%%.*}" +%s 2>/dev/null) || return
  remaining=$((epoch - now))

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

get_access_token() {
  local svc now_ms token expires
  now_ms=$(date +%s)000

  # Find the latest valid Claude Code credentials in keychain
  security dump-keychain 2>/dev/null \
    | grep -o '"Claude Code-credentials[^"]*"' \
    | tr -d '"' \
    | sort -u \
    | while IFS= read -r svc; do
        token=$(security find-generic-password -s "$svc" -w 2>/dev/null) || continue
        expires=$(echo "$token" | jq -r '.claudeAiOauth.expiresAt // 0' 2>/dev/null)
        if [[ "$expires" -gt "$now_ms" ]]; then
          echo "$token" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null
          return
        fi
      done
}

get_rate_limit() {
  local now
  now=$(date +%s)

  # Check cache
  if [[ -f "$CACHE_FILE" ]]; then
    local cached_at age
    cached_at=$(jq -r '.cached_at // 0' "$CACHE_FILE" 2>/dev/null)
    age=$((now - cached_at))
    if ((age < CACHE_TTL)); then
      jq -r 'del(.cached_at)' "$CACHE_FILE" 2>/dev/null
      return
    fi
  fi

  # Get valid OAuth token
  local access_token
  access_token=$(get_access_token)
  [[ -z "$access_token" ]] && return

  # Fetch usage API
  local response
  response=$(curl -sf --max-time 5 \
    -H "Authorization: Bearer ${access_token}" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null) || return

  # Cache response
  echo "$response" | jq --arg ts "$now" '. + {cached_at: ($ts | tonumber)}' > "$CACHE_FILE" 2>/dev/null

  echo "$response"
}

main() {
  local input model_name used_pct model_color percent_color

  input=$(cat)
  model_name=$(jq -r '.model.display_name' <<< "$input")
  used_pct=$(jq -r '.context_window.used_percentage // 0' <<< "$input")

  percent_color=$(get_context_color "$used_pct")
  model_color=$(get_model_color "$model_name")

  # Rate limit
  local usage five_pct seven_pct five_color seven_color five_reset seven_reset five_cd seven_cd
  usage=$(get_rate_limit)

  if [[ -n "$usage" ]]; then
    five_pct=$(jq -r '.five_hour.utilization // 0 | floor' <<< "$usage" 2>/dev/null || echo 0)
    seven_pct=$(jq -r '.seven_day.utilization // 0 | floor' <<< "$usage" 2>/dev/null || echo 0)
    five_reset=$(jq -r '.five_hour.resets_at // empty' <<< "$usage" 2>/dev/null)
    seven_reset=$(jq -r '.seven_day.resets_at // empty' <<< "$usage" 2>/dev/null)
    five_cd=$(format_countdown "$five_reset")
    seven_cd=$(format_countdown "$seven_reset")
    five_color=$(get_5h_color "$five_pct")
    seven_color=$(get_7d_color "$seven_pct")

    printf "\033[0m\033[38;5;%dm󰚩 %s\033[0m \033[38;5;%dm %s%%\033[0m \033[38;5;%dm󰔛 %s%%\033[38;5;246m ↺%s\033[0m \033[38;5;%dm󰃭 %s%%\033[38;5;246m ↺%s\033[0m\n" \
      "$model_color" "$model_name" "$percent_color" "$used_pct" \
      "$five_color" "$five_pct" "$five_cd" \
      "$seven_color" "$seven_pct" "$seven_cd"
  else
    printf "\033[0m\033[38;5;%dm󰚩 %s\033[0m \033[38;5;%dm %s%%\033[0m\n" \
      "$model_color" "$model_name" "$percent_color" "$used_pct"
  fi
}

main
