#!/bin/bash
set -euo pipefail

MAIN_PANE="${1:-}"
SIDEBAR_MARKER="tmux-sidebar"
SIDEBAR_BIN="$HOME/.config/scripts/tmux-sidebar/target/release/tmux-sidebar"

if [[ -z "$MAIN_PANE" ]]; then
    echo "Usage: toggle.sh <pane_id>" >&2
    exit 1
fi

if [[ ! -x "$SIDEBAR_BIN" ]]; then
    echo "Binary not found: $SIDEBAR_BIN" >&2
    exit 1
fi

# Find existing sidebar pane
SIDEBAR_PANE=$(tmux list-panes -F '#{pane_id}:#{pane_title}' | grep ":$SIDEBAR_MARKER$" | cut -d: -f1 || true)

if [[ -n "$SIDEBAR_PANE" ]]; then
    tmux kill-pane -t "$SIDEBAR_PANE"
else
    tmux split-window -h -l 25% -t "$MAIN_PANE" "$SIDEBAR_BIN" "$MAIN_PANE"
    tmux select-pane -T "$SIDEBAR_MARKER"
    tmux select-pane -t "$MAIN_PANE"
fi
