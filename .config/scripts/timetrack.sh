#!/bin/bash

# timetrack.sh
# A simple time tracking script
#

CATEGORIES=(
  "VENDURE"
  "WORKFLOW"
  "PROGRAMMING"
  "LEARNING"
  "WASTED"
  "STOP"
)

selected=$(printf "%s\n" "${CATEGORIES[@]}" | sk --margin 10% --color="bw")

if [[ $selected == "STOP" ]]; then
  timew stop
  # tmux set -g status-right "#[fg=black,bg=red,bold] $selected "
else
  timew start "$selected"
  # tmux set -g status-right "#[fg=black,bg=green,bold] $selected "
fi
