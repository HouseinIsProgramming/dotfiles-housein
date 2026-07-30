#!/bin/bash
set -euo pipefail

DATA_DIR="$HOME/.local/share/ghostty-notify"
MAP_FILE="$DATA_DIR/session-map.json"
NOTIF_FILE="$DATA_DIR/notifications.json"
LOCK_DIR="/tmp/ghostty-notify.lock"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Waiting for input"')

[ -z "$SESSION_ID" ] && exit 0
[ -f "$MAP_FILE" ] || exit 0

SESSION_INFO=$(jq -r --arg sid "$SESSION_ID" '.[$sid] // empty' "$MAP_FILE")
[ -z "$SESSION_INFO" ] && exit 0

TERMINAL_ID=$(echo "$SESSION_INFO" | jq -r '.terminal_id')
WORKING_DIR=$(echo "$SESSION_INFO" | jq -r '.working_dir')
CWD=$(echo "$SESSION_INFO" | jq -r '.cwd')
NAME=$(echo "$SESSION_INFO" | jq -r '.name')

mkdir -p "$DATA_DIR"

# Acquire lock (with stale detection and timeout)
LOCK_ATTEMPTS=0
while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    if [ -d "$LOCK_DIR" ]; then
        LOCK_AGE=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR" 2>/dev/null || echo "$(date +%s)") ))
        [ "$LOCK_AGE" -gt 10 ] && rmdir "$LOCK_DIR" 2>/dev/null && continue
    fi
    sleep 0.05
    LOCK_ATTEMPTS=$((LOCK_ATTEMPTS + 1))
    [ "$LOCK_ATTEMPTS" -ge 100 ] && exit 0
done
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

[ -f "$NOTIF_FILE" ] && NOTIFS=$(cat "$NOTIF_FILE") || NOTIFS='[]'

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EXISTS=$(echo "$NOTIFS" | jq --arg sid "$SESSION_ID" '[.[] | select(.session_id == $sid)] | length')

if [ "$EXISTS" -gt "0" ]; then
    # Update existing notification
    NOTIFS=$(echo "$NOTIFS" | jq \
        --arg sid "$SESSION_ID" \
        --arg ts "$TIMESTAMP" \
        --arg msg "$MESSAGE" \
        '[.[] | if .session_id == $sid then .timestamp = $ts | .message = $msg else . end]')
else
    # Append new notification
    NOTIFS=$(echo "$NOTIFS" | jq \
        --arg sid "$SESSION_ID" \
        --arg tid "$TERMINAL_ID" \
        --arg wdir "$WORKING_DIR" \
        --arg cwd "$CWD" \
        --arg name "$NAME" \
        --arg msg "$MESSAGE" \
        --arg ts "$TIMESTAMP" \
        '. + [{session_id: $sid, terminal_id: $tid, working_dir: $wdir, cwd: $cwd, name: $name, message: $msg, timestamp: $ts}]')
fi

TMP=$(mktemp /tmp/ghostty-notify.XXXXXX)
echo "$NOTIFS" > "$TMP"
mv "$TMP" "$NOTIF_FILE"
