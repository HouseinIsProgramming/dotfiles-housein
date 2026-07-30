#!/bin/bash
set -euo pipefail

DATA_DIR="$HOME/.local/share/ghostty-notify"
NOTIF_FILE="$DATA_DIR/notifications.json"
LOCK_DIR="/tmp/ghostty-notify.lock"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

[ -z "$SESSION_ID" ] && exit 0
[ -f "$NOTIF_FILE" ] || exit 0

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

NOTIFS=$(cat "$NOTIF_FILE")
NOTIFS=$(echo "$NOTIFS" | jq --arg sid "$SESSION_ID" '[.[] | select(.session_id != $sid)]')

TMP=$(mktemp /tmp/ghostty-notify.XXXXXX)
echo "$NOTIFS" > "$TMP"
mv "$TMP" "$NOTIF_FILE"
