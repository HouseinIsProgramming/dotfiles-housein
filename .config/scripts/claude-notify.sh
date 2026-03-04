#!/usr/bin/env bash
# Claude Code notification widget for tmux status bar
# Subcommands: add, dismiss, click-first, rebuild

set -euo pipefail

STATE_FILE="$HOME/.cache/claude-notifications.json"
CACHE_DIR="$HOME/.cache"

ensure_state() {
  [[ -d "$CACHE_DIR" ]] || mkdir -p "$CACHE_DIR"
  [[ -f "$STATE_FILE" ]] || echo '[]' > "$STATE_FILE"
}

cmd_add() {
  ensure_state

  local input
  input=$(cat)

  local cwd
  cwd=$(echo "$input" | jq -r '.cwd // empty')
  [[ -z "$cwd" ]] && exit 0

  local pane="${TMUX_PANE:-}"
  [[ -z "$pane" ]] && exit 0

  local win_index session_name
  win_index=$(tmux display-message -p -t "$pane" '#{window_index}' 2>/dev/null) || exit 0
  session_name=$(tmux display-message -p -t "$pane" '#{session_name}' 2>/dev/null) || exit 0

  local label
  label=$(echo "$session_name" | cut -c1-3 | tr '[:upper:]' '[:lower:]')

  osascript -e "display notification \"Session '$session_name' needs attention\" with title \"Claude\"" &>/dev/null &

  # Skip if this window already has a notification
  local existing
  existing=$(jq -r --arg w "$win_index" '[.[] | select(.window == $w)] | length' "$STATE_FILE")
  [[ "$existing" -gt 0 ]] && exit 0

  local ts
  ts=$(date +%s)
  jq --arg l "$label" --arg w "$win_index" --arg p "$pane" --arg t "$ts" \
    '. += [{"label": $l, "window": $w, "pane": $p, "ts": ($t | tonumber)}]' \
    "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

  cmd_rebuild
}

cmd_dismiss() {
  ensure_state
  local win_index="${1:-}"
  [[ -z "$win_index" ]] && exit 0

  jq --arg w "$win_index" '[.[] | select(.window != $w)]' \
    "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

  cmd_rebuild
}

cmd_click_first() {
  ensure_state
  local first_window
  first_window=$(jq -r '.[0].window // empty' "$STATE_FILE")
  [[ -z "$first_window" ]] && exit 0

  tmux select-window -t ":${first_window}" 2>/dev/null || true
}

cmd_rebuild() {
  ensure_state
  local built=""

  while IFS= read -r entry; do
    local label window
    label=$(echo "$entry" | jq -r '.label')
    window=$(echo "$entry" | jq -r '.window')
    built+="#[fg=colour3,bold] ${label} #[default]"
  done < <(jq -c '.[]' "$STATE_FILE")

  tmux set -g @claude_notify "$built" 2>/dev/null || true
  tmux refresh-client -S 2>/dev/null || true
}

case "${1:-}" in
  add)         cmd_add ;;
  dismiss)     cmd_dismiss "${2:-}" ;;
  click-first) cmd_click_first ;;
  rebuild)     cmd_rebuild ;;
  *)           echo "Usage: $0 {add|dismiss|click-first|rebuild}" >&2; exit 1 ;;
esac
