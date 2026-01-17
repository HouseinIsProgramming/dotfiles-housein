#!/bin/bash

pane_id="$TMUX_PANE"
input=$(tmux show-buffer 2>/dev/null | tr -d '[:space:]')

# Extract filename and line number
if [[ "$input" =~ :([0-9]+)$ ]]; then
  line="${BASH_REMATCH[1]}"
  filename="${input%:*}"
else
  line="1"
  filename="$input"
fi

# Strip path if present, get just the filename for searching
searchname=$(basename "$filename")

# fzf find the file, pre-fill the search
selected=$(fd --type f | fzf --query="$searchname" --select-1 --exit-0)

if [ -n "$selected" ]; then
  tmux new-window "nvim +$line \"$selected\""
fi
