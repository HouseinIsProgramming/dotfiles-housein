#!/usr/bin/env bash

# Parse Host entries from ssh config, excluding wildcards and patterns
hosts=$(grep -E "^Host " ~/.ssh/config | awk '{print $2}' | grep -v '[*?]')

if [[ -z "$hosts" ]]; then
    echo "No SSH hosts found in ~/.ssh/config"
    exit 1
fi

selected=$(echo "$hosts" | sk --margin 10% --color="bw" --prompt="ssh > ")

if [[ -z "$selected" ]]; then
    exit 0
fi

tmux new-window -n "$selected" "ssh $selected"
