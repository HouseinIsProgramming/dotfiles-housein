SESSION="$(basename "$PWD")"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux new-window -t "$SESSION" -c "$PWD"
    tmux attach -t "$SESSION"
else
    tmux new-session -s "$SESSION" -c "$PWD"
fi
