---
description: Get output from a tmux window
argument-hint: [window-name] [lines] [num-commands]
---

!if [ -z "$ARGUMENTS" ]; then
tmux list-windows -F '#{window_index}: #{window_name} (#{pane_current_command})' 2>/dev/null || echo "Not in tmux"
else
WINDOW=$(echo "$ARGUMENTS" | awk '{print $1}')
  LINES=$(echo "$ARGUMENTS" | awk '{print $2}')
  LINES=${LINES:-100}
NUMCMDS=$(echo "$ARGUMENTS" | awk '{print $3}')

OUTPUT=$(tmux capture-pane -t "$WINDOW" -p -S -"$LINES" 2>/dev/null) || { echo "Window '$WINDOW' not found"; exit 1; }

if [ -n "$NUMCMDS" ]; then
echo "$OUTPUT" | tac | awk '/^\$ /{n++} n<='"$NUMCMDS" | tac
else
echo "$OUTPUT"
fi
fi
