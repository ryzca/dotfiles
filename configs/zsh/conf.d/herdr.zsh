# herdr workspace management functions
# Uses the single default session; projects are separated by workspaces

_herdr_server_running() {
    herdr status server 2>/dev/null | grep -q '^status: running'
}

_herdr_workspace_id_by_label() {
    herdr workspace list 2>/dev/null |
        jq -r --arg label "$1" '.result.workspaces[] | select(.label == $label) | .workspace_id' |
        head -n1
}

# Attach to the default session
# Usage: h
h() {
    if [[ -z "$HERDR_PANE_ID" ]]; then
        herdr
    fi
}

# Focus (or create) a workspace, then attach
# Usage: hw [workspace_label]  (defaults to current directory name)
hw() {
    local label="${1:-$(basename "$PWD")}"

    if ! _herdr_server_running; then
        (herdr server &>/dev/null &)
        local i
        for i in {1..50}; do
            _herdr_server_running && break
            sleep 0.1
        done
    fi

    local ws_id="$(_herdr_workspace_id_by_label "$label")"
    if [[ -n "$ws_id" ]]; then
        herdr workspace focus "$ws_id" >/dev/null
    else
        herdr workspace create --cwd "$PWD" --label "$label" --focus >/dev/null
    fi

    if [[ -z "$HERDR_PANE_ID" ]]; then
        herdr
    fi
}

# Close workspace
# Usage: hk [workspace_label]
hk() {
    local label="${1:-$(basename "$PWD")}"
    local ws_id="$(_herdr_workspace_id_by_label "$label")"

    if [[ -n "$ws_id" ]]; then
        herdr workspace close "$ws_id" >/dev/null &&
        echo "Closed workspace: $label"
    else
        echo "Workspace not found: $label"
    fi
}

# List workspaces
hl() {
    herdr workspace list 2>/dev/null |
        jq -r '.result.workspaces[] | [.workspace_id, .label, "tabs:\(.tab_count)", .agent_status] | @tsv'
}

# Fuzzy finder for workspaces (requires fzf)
hs() {
    local selected
    selected=$(herdr workspace list 2>/dev/null |
        jq -r '.result.workspaces[] | "\(.workspace_id)\t\(.label)"' |
        fzf --exit-0 --with-nth=2) || return

    herdr workspace focus "${selected%%$'\t'*}" >/dev/null

    if [[ -z "$HERDR_PANE_ID" ]]; then
        herdr
    fi
}
