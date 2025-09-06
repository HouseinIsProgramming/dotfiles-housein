#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # selected=$(find ~/Documents/Github ~/Documents/Work/ ~/dotfiles-housein/ -mindepth 1 -maxdepth 2 -type d | \
    #     sed "s|^$HOME/||" | \
    #     sk --margin 10% --color="bw" 
    # )

    crawled_paths=$(find ~/Documents/Github -mindepth 1 -maxdepth 2 -type d | sed "s|^$HOME/||")

    # The directory you want to add without crawling its contents, formatted
    uncrawled_path="~/dotfiles-housein/" # Assuming it's directly under $HOME/Documents/Work

    selected=$( \
        {
            echo "$crawled_paths"
            echo "$uncrawled_path"
        } | \
        sk --margin 10% --color="bw"
    )

    # Add home path back
    if [[ -n "$selected" ]]; then
        selected="$HOME/$selected"
    fi
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected 
    # select first window
    tmux select-window -t $selected_name:1
fi

tmux switch-client -t $selected_name
