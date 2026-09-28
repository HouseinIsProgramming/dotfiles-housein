#!/bin/bash
# Mac port of omarchy's focus-or-back for web apps living in Arc tabs.
# Focus the first Arc tab whose URL contains <match> (any window, any space),
# open <url> in a new tab if none exists, and if that tab is already focused
# jump back to the app that was frontmost before.
# usage: arc-focus-or-back.sh <match> <url>

if (($# < 2)); then
  echo "Usage: arc-focus-or-back.sh <url-match> <url>"
  exit 1
fi

MATCH="$1"
URL="$2"
STATE="${TMPDIR:-/tmp}/arc-focus-or-back.prev"

front=$(osascript -e 'tell application "System Events" to get bundle identifier of first application process whose frontmost is true')

if [[ "$front" == "company.thebrowser.Browser" ]]; then
  active=$(osascript -e 'tell application "Arc" to get URL of active tab of front window' 2>/dev/null)
  if [[ "$active" == *"$MATCH"* ]]; then
    prev=$(cat "$STATE" 2>/dev/null)
    [[ -n "$prev" && "$prev" != "company.thebrowser.Browser" ]] && open -b "$prev"
    exit 0
  fi
fi

echo "$front" > "$STATE"

osascript - "$MATCH" "$URL" <<'APPLESCRIPT'
on run argv
  set theMatch to item 1 of argv
  set theURL to item 2 of argv
  tell application "Arc"
    -- Arc rejects the references that `whose` and `repeat with x in` hand back,
    -- so address everything by index.
    repeat with wi from 1 to count of windows
      repeat with si from 1 to count of spaces of window wi
        set urls to URL of every tab of space si of window wi
        repeat with ti from 1 to count of urls
          if item ti of urls contains theMatch then
            tell space si of window wi to focus
            tell tab ti of space si of window wi to select
            activate
            return
          end if
        end repeat
      end repeat
    end repeat
    if (count of windows) is 0 then
      make new window
    end if
    tell front window to make new tab with properties {URL:theURL}
    activate
  end tell
end run
APPLESCRIPT
# `activate` from a background script is often ignored on recent macOS; open -b isn't.
open -b company.thebrowser.Browser
