#!/bin/bash
# Toggle tmux-sidebar pane

MAIN_PANE="$1"
SIDEBAR_MARKER="tmux-sidebar"
SIDEBAR_BIN="$HOME/.config/scripts/tmux-sidebar/target/release/tmux-sidebar"

# Find existing sidebar pane in current window
SIDEBAR_PANE=$(tmux list-panes -F '#{pane_id}:#{pane_title}' | grep ":$SIDEBAR_MARKER$" | cut -d: -f1)

if [ -n "$SIDEBAR_PANE" ]; then
    # Sidebar exists - kill it
    tmux kill-pane -t "$SIDEBAR_PANE"
else
    # Create sidebar on the right, 25% width
    tmux split-window -h -l 25% -t "$MAIN_PANE" "$SIDEBAR_BIN $MAIN_PANE"
    # Mark the new pane
    tmux select-pane -T "$SIDEBAR_MARKER"
    # Return focus to main pane
    tmux select-pane -t "$MAIN_PANE"
fi
