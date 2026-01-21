#!/bin/bash
# Toggle tmux popup with persistent session

session="_popup_$(tmux display -p '#S')"

if ! tmux has -t "$session" 2> /dev/null; then
  session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}' -c "$(tmux display -p '#{pane_current_path}')")"
  tmux set-option -s -t "$session_id" status off
  session="$session_id"
fi

exec tmux attach -t "$session"
