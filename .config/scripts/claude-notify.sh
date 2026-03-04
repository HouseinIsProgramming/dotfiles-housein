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

  # Label: first 3 chars + optional -N suffix from session name
  local base suffix label
  if [[ "$session_name" =~ -([0-9]+)$ ]]; then
    suffix="-${BASH_REMATCH[1]}"
    base="${session_name%-${BASH_REMATCH[1]}}"
  else
    suffix=""
    base="$session_name"
  fi
  label=$(echo "$base" | cut -c1-3 | tr '[:upper:]' '[:lower:]')${suffix}

  # Skip notification if the notifying pane is already focused and Ghostty is frontmost
  local active_pane active_window active_session
  active_session=$(tmux display-message -p '#{session_name}' 2>/dev/null) || active_session=""
  active_window=$(tmux display-message -p '#{window_index}' 2>/dev/null) || active_window=""
  active_pane=$(tmux display-message -p '#{pane_id}' 2>/dev/null) || active_pane=""
  if [[ "$active_session" == "$session_name" && "$active_window" == "$win_index" && "$active_pane" == "$pane" ]]; then
    local frontapp
    frontapp=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null) || frontapp=""
    [[ "${frontapp,,}" == "ghostty" ]] && exit 0
  fi

  local pane_title
  pane_title=$(tmux display-message -p -t "$pane" '#{pane_title}' 2>/dev/null) || pane_title="$win_index"
  # Escape single quotes for AppleScript/Lua
  pane_title="${pane_title//\'/\\\'}"
  local session_display="${session_name//\'/\\\'}"
  osascript -e "tell application \"Hammerspoon\" to execute lua code \"showClaudeNotify('$session_display', '$pane_title')\"" &>/dev/null &

  # Skip if this session+window already has a notification
  local existing
  existing=$(jq -r --arg s "$session_name" --arg w "$win_index" \
    '[.[] | select(.session == $s and .window == $w)] | length' "$STATE_FILE")
  [[ "$existing" -gt 0 ]] && exit 0

  local ts
  ts=$(date +%s)
  jq --arg l "$label" --arg w "$win_index" --arg s "$session_name" --arg p "$pane" --arg t "$ts" \
    '. += [{"label": $l, "window": $w, "session": $s, "pane": $p, "ts": ($t | tonumber)}]' \
    "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

  cmd_rebuild
}

cmd_dismiss() {
  ensure_state
  local session_name="${1:-}"
  local win_index="${2:-}"
  [[ -z "$session_name" || -z "$win_index" ]] && exit 0

  jq --arg s "$session_name" --arg w "$win_index" \
    '[.[] | select(.session != $s or .window != $w)]' \
    "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

  cmd_rebuild
}

cmd_click_first() {
  ensure_state
  local first_session first_window
  first_session=$(jq -r '.[0].session // empty' "$STATE_FILE")
  first_window=$(jq -r '.[0].window // empty' "$STATE_FILE")
  [[ -z "$first_session" || -z "$first_window" ]] && exit 0

  tmux switch-client -t "=${first_session}:${first_window}" 2>/dev/null || true
}

cmd_rebuild() {
  ensure_state
  local built=""

  # Group by label, count occurrences
  while IFS= read -r group; do
    [[ -z "$group" ]] && continue
    local label count
    label=$(echo "$group" | jq -r '.label')
    count=$(echo "$group" | jq -r '.count')
    if [[ "$count" -gt 1 ]]; then
      built+="#[bg=colour3,fg=black,bold] ${count} ${label} #[default] "
    else
      built+="#[bg=colour3,fg=black,bold] ${label} #[default] "
    fi
  done < <(jq -c 'group_by(.label) | .[] | {label: .[0].label, count: length}' "$STATE_FILE")

  tmux set -g @claude_notify "$built" 2>/dev/null || true
  tmux refresh-client -S 2>/dev/null || true
}

case "${1:-}" in
  add)         cmd_add ;;
  dismiss)     cmd_dismiss "${2:-}" "${3:-}" ;;
  click-first) cmd_click_first ;;
  rebuild)     cmd_rebuild ;;
  *)           echo "Usage: $0 {add|dismiss|click-first|rebuild}" >&2; exit 1 ;;
esac
