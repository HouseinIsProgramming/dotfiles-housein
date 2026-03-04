#!/usr/bin/env bash
# Claude Code notification widget for tmux status bar
# Subcommands: add, dismiss, click, rebuild

set -euo pipefail

STATE_FILE="$HOME/.cache/claude-notifications.json"
CACHE_DIR="$HOME/.cache"

# Ensure state file exists
ensure_state() {
  [[ -d "$CACHE_DIR" ]] || mkdir -p "$CACHE_DIR"
  [[ -f "$STATE_FILE" ]] || echo '[]' > "$STATE_FILE"
}

cmd_add() {
  ensure_state

  # Read hook JSON from stdin
  local input
  input=$(cat)

  local cwd
  cwd=$(echo "$input" | jq -r '.cwd // empty')
  [[ -z "$cwd" ]] && exit 0

  # Get window/session info from TMUX_PANE
  local pane="${TMUX_PANE:-}"
  [[ -z "$pane" ]] && exit 0

  local win_index session_name
  win_index=$(tmux display-message -p -t "$pane" '#{window_index}' 2>/dev/null) || exit 0
  session_name=$(tmux display-message -p -t "$pane" '#{session_name}' 2>/dev/null) || exit 0

  # Label: session name (truncated to 3 chars lowercase for badge)
  local label
  label=$(echo "$session_name" | cut -c1-3 | tr '[:upper:]' '[:lower:]')

  # macOS toast notification
  osascript -e "display notification \"Session '$session_name' needs attention\" with title \"Claude\"" &>/dev/null &

  # Skip if this window already has a notification
  local existing
  existing=$(jq -r --arg w "$win_index" '[.[] | select(.window == $w)] | length' "$STATE_FILE")
  if [[ "$existing" -gt 0 ]]; then
    exit 0
  fi

  # Append entry
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

cmd_click() {
  local range_label="${1:-}"
  [[ -z "$range_label" ]] && exit 0

  # Extract window index from "goto-N" label
  local win_index="${range_label#goto-}"
  [[ "$win_index" == "$range_label" ]] && exit 0

  tmux select-window -t ":${win_index}" 2>/dev/null || true
  # Dismiss happens via after-select-window hook
}

cmd_rebuild() {
  ensure_state
  local built=""

  # Build clickable badge string from state
  while IFS= read -r entry; do
    local label window
    label=$(echo "$entry" | jq -r '.label')
    window=$(echo "$entry" | jq -r '.window')
    built+="#[range=user|goto-${window} fg=colour3 bold] ${label} #[norange]"
  done < <(jq -c '.[]' "$STATE_FILE")

  tmux set -g @claude_notify "$built" 2>/dev/null || true
}

case "${1:-}" in
  add)     cmd_add ;;
  dismiss) cmd_dismiss "${2:-}" ;;
  click)   cmd_click "${2:-}" ;;
  rebuild) cmd_rebuild ;;
  *)       echo "Usage: $0 {add|dismiss|click|rebuild}" >&2; exit 1 ;;
esac
