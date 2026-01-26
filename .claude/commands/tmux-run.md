---
description: Run a command in a new tmux window
argument-hint: <window-name> <command>
---

!WINDOW=$(echo "$ARGUMENTS" | awk '{print $1}')
COMMAND=$(echo "$ARGUMENTS" | cut -d' ' -f2-)

if [ -z "$WINDOW" ] || [ -z "$COMMAND" ]; then
  echo "Usage: /tmux-run <window-name> <command>"
  exit 1
fi

if ! tmux info >/dev/null 2>&1; then
  echo "Not in tmux session"
  exit 1
fi

if tmux list-windows -F '#{window_name}' 2>/dev/null | grep -q "^${WINDOW}$"; then
  echo "Window '$WINDOW' already exists"
  exit 1
fi

tmux new-window -n "$WINDOW" "$COMMAND" && echo "Started '$COMMAND' in window: $WINDOW"
