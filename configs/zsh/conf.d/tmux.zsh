# tmux session management functions

# Create or attach to tmux session
# Usage: tm [session_name]
tm() {
    local session_name="${1:-$(basename "$PWD")}"

    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Attaching to existing session: $session_name"
        tmux attach-session -t "$session_name"
    else
        echo "Creating new session: $session_name"
        tmux new-session -d -s "$session_name" -c "$PWD"
        tmux attach-session -t "$session_name"
    fi
}

# Kill tmux session
# Usage: tk [session_name]
tk() {
    local session_name="${1:-$(basename "$PWD")}"

    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux kill-session -t "$session_name"
        echo "Killed session: $session_name"
    else
        echo "Session not found: $session_name"
    fi
}

# List tmux sessions
alias tl='tmux list-sessions'

# Fuzzy finder for tmux sessions (requires fzf)
ts() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&
    tmux attach-session -t "$session"
}