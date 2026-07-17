#!/bin/sh
# Sync the herdr pane title with the Claude session title.
# Claude Code writes the session title to the terminal title; herdr tracks it
# per pane as terminal_title_stripped. This hook copies it to the manual pane
# name so it shows on the pane border. No-op outside herdr.

set -eu

action="${1:-sync}"

# consume hook input on stdin
cat >/dev/null 2>&1 || true

[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v herdr >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

case "$action" in
  sync)
    title="$(herdr pane get "$HERDR_PANE_ID" 2>/dev/null |
      jq -r '.result.pane.terminal_title_stripped // empty')"
    [ -n "$title" ] || exit 0
    # generic title before the session gets a real one: nothing to show
    [ "$title" = "Claude Code" ] && exit 0
    herdr pane rename "$HERDR_PANE_ID" "$title" >/dev/null 2>&1 || true
    ;;
  clear)
    herdr pane rename "$HERDR_PANE_ID" --clear >/dev/null 2>&1 || true
    ;;
esac

exit 0
