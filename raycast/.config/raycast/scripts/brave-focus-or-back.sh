#!/bin/bash
# Mac port of omarchy's focus-or-back for web apps living in Brave tabs.
# The work happens in brave-focus-or-back.swift; this compiles it on first use
# (and after edits) and runs it.
# usage: brave-focus-or-back.sh <match> <url>

DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="${XDG_CACHE_HOME:-$HOME/.cache}/brave-focus-or-back/brave-focus-or-back"

if [[ ! "$BIN" -nt "$DIR/brave-focus-or-back.swift" ]]; then
  mkdir -p "$(dirname "$BIN")"
  swiftc -O -o "$BIN" "$DIR/brave-focus-or-back.swift" || exit 1
fi

exec "$BIN" "$@"
