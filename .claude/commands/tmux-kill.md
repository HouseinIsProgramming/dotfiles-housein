---
description: Kill a tmux window by name
argument-hint: <window-name>
---

!WINDOW="$ARGUMENTS"

if [ -z "$WINDOW" ]; then
  echo "Usage: /tmux-kill <window-name>"
  echo ""
  tmux list-windows -F '#{window_index}: #{window_name} (#{pane_current_command})' 2>/dev/null || echo "Not in tmux"
  exit 1
fi

if tmux kill-window -t "$WINDOW" 2>/dev/null; then
  echo "Killed window: $WINDOW"
else
  echo "Window '$WINDOW' not found"
  exit 1
fi
