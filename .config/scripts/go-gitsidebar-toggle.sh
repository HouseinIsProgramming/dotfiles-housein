#!/bin/bash
set -euo pipefail

MAIN_PANE="${1:-}"
SIDEBAR_MARKER="go-gitsidebar"
SIDEBAR_BIN="$HOME/go/bin/go-gitsidebar"

if [[ -z "$MAIN_PANE" ]]; then
    echo "Usage: go-gitsidebar-toggle.sh <pane_id>" >&2
    exit 1
fi

# Find existing sidebar pane
SIDEBAR_PANE=$(tmux list-panes -F '#{pane_id}:#{pane_title}' | grep ":$SIDEBAR_MARKER$" | cut -d: -f1 || true)

if [[ -n "$SIDEBAR_PANE" ]]; then
    tmux kill-pane -t "$SIDEBAR_PANE"
else
    REPO_DIR=$(tmux display-message -p -t "$MAIN_PANE" '#{pane_current_path}')
    GIT_ROOT=$(git -C "$REPO_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$REPO_DIR")
    tmux split-window -h -l 55 -t "$MAIN_PANE" "$SIDEBAR_BIN" --dir "$GIT_ROOT"
    tmux select-pane -T "$SIDEBAR_MARKER"
    tmux select-pane -t "$MAIN_PANE"
fi
