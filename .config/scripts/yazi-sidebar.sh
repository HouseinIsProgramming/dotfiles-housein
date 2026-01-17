#!/bin/bash
# Toggle yazi sidebar that tracks main pane's PWD

CURRENT_PANE="$1"
SIDEBAR_MARKER="yazi-sidebar"

# Find existing sidebar pane
SIDEBAR_PANE=$(tmux list-panes -F '#{pane_id}:#{pane_title}' | grep ":$SIDEBAR_MARKER$" | cut -d: -f1)

# Check if current pane IS the sidebar
CURRENT_TITLE=$(tmux display-message -p -t "$CURRENT_PANE" '#{pane_title}')

if [ "$CURRENT_TITLE" = "$SIDEBAR_MARKER" ]; then
    # We're in sidebar - close it
    tmux kill-pane -t "$CURRENT_PANE"
elif [ -n "$SIDEBAR_PANE" ]; then
    # Sidebar exists, we're in main pane - kill and recreate with current PWD
    tmux kill-pane -t "$SIDEBAR_PANE"
    MAIN_PWD=$(tmux display-message -p -t "$CURRENT_PANE" '#{pane_current_path}')
    tmux split-window -hb -l 25% -t "$CURRENT_PANE" -c "$MAIN_PWD" "yazi '$MAIN_PWD'"
    tmux select-pane -T "$SIDEBAR_MARKER"
    tmux select-pane -t "$CURRENT_PANE"
else
    # No sidebar - create it
    MAIN_PWD=$(tmux display-message -p -t "$CURRENT_PANE" '#{pane_current_path}')
    tmux split-window -hb -l 25% -t "$CURRENT_PANE" -c "$MAIN_PWD" "yazi '$MAIN_PWD'"
    tmux select-pane -T "$SIDEBAR_MARKER"
    tmux select-pane -t "$CURRENT_PANE"
fi
