#!/bin/bash

# timetrack.sh
# A simple time tracking script
# and focus mode script

CATEGORIES=(
  "VENDURE"
  "WORKFLOW"
  "PROGRAMMING"
  "LEARNING"
  "WASTED"
  "STOP"
)

clear_blocks() {
  hostess rm studio.youtube.com
  hostess rm www.youtube.com
  hostess rm www.reddit.com
  hostess rm www.x.com
  hostess rm www.linkedin.com
}

add_distraction_blocks() {
  hostess add studio.youtube.com 127.0.0.1
  hostess add www.youtube.com 127.0.0.1
  hostess add www.reddit.com 127.0.0.1
  hostess add www.x.com 127.0.0.1
  hostess add www.linkedin.com 127.0.0.1
}

selected=$(printf "%s\n" "${CATEGORIES[@]}" | sk --margin 30% --color="bw")

if [[ -z "$selected" ]]; then
  echo "No category selected. Exiting."
  exit 1
fi

if [[ "$selected" == "STOP" ]]; then
  timew stop
  clear_blocks # Clear all blocks when stopping time tracking
  # tmux set -g status-right "#[fg=black,bg=red,bold] $selected "
else
  timew start "$selected"
  # tmux set -g status-right "#[fg=black,bg=green,bold] $selected "

  if [[ "$selected" == "WASTED" || "$selected" == "WORKFLOW" ]]; then
    clear_blocks
  elif [[ "$selected" == "VENDURE" ]]; then
    add_distraction_blocks
    hostess rm www.reddit.com
    hostess rm www.linkedin.com
    hostess rm www.x.com
    hostess rm www.youtube.com
  else
    add_distraction_blocks
  fi
fi
