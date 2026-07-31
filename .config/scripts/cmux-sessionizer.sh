#!/usr/bin/env bash
set -euo pipefail

# cmux-sessionizer: fuzzy-pick a project directory, then switch to its cmux
# workspace or create one. Per-project layouts/commands/env live in
# ~/.config/cmux-sessionizer/ — nothing is written into project directories.

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/cmux-sessionizer"
CONFIG_FILE="$CONFIG_DIR/config.json"
PROJECTS_DIR="$CONFIG_DIR/projects"
export CMUX_QUIET=1

# External pickers (Hammerspoon, Raycast) run with a minimal PATH and
# outside cmux, so they need the socket password (automation.socketControlMode=password)
PATH="$PATH:/opt/homebrew/bin:/Applications/cmux.app/Contents/Resources/bin"
if [[ -z "${CMUX_SOCKET_PASSWORD:-}" && -r "$HOME/.config/cmux/sessionizer-socket-password" ]]; then
    export CMUX_SOCKET_PASSWORD="$(<"$HOME/.config/cmux/sessionizer-socket-password")"
fi

die() {
    echo "cmux-sessionizer: $*" >&2
    exit 1
}

command -v jq >/dev/null || die "jq is required"
command -v cmux >/dev/null || die "cmux CLI not found"

expand_path() {
    local p="$1"
    [[ "$p" == "~" ]] && p="$HOME"
    printf '%s\n' "${p/#\~\//$HOME/}"
}

# Walk the configured search paths. Kept sequential on purpose: running the
# finds concurrently measured slower here (46ms vs 34ms) because the temp-file
# and fork overhead outweighs any overlap at this number of search paths.
scan_candidates() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS=$'\t' read -r path min max; do
            find "$(expand_path "$path")" -mindepth "$min" -maxdepth "$max" -type d 2>/dev/null
        done < <(jq -r '.search_paths[]? | [.path, (.min_depth // 1), (.max_depth // 2)] | @tsv' "$CONFIG_FILE")

        while IFS= read -r p; do
            expand_path "$p"
        done < <(jq -r '.extra_paths[]?' "$CONFIG_FILE")
    fi

    # Directories from project configs are always selectable
    for f in "$PROJECTS_DIR"/*.json; do
        [[ -e "$f" ]] || continue
        local dir
        dir="$(jq -r '.dir // empty' "$f")"
        [[ -n "$dir" ]] && expand_path "$dir"
    done
}

# Serve the cached list immediately, then refresh it in the background so the
# next run is current. The cache is bypassed when the config is newer than it,
# so a project added to ~/.config/cmux-sessionizer shows up right away.
candidates() {
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/cmux-sessionizer"
    local cache="$cache_dir/candidates"
    local fresh=1

    [[ -s "$cache" ]] || fresh=0
    [[ -f "$CONFIG_FILE" && "$CONFIG_FILE" -nt "$cache" ]] && fresh=0
    [[ -d "$PROJECTS_DIR" && "$PROJECTS_DIR" -nt "$cache" ]] && fresh=0

    if (( fresh )); then
        cat "$cache"
        # Detach so a slow rescan can't hold the picker's stdout open.
        ( scan_candidates >"$cache.$$" 2>/dev/null &&
              mv -f "$cache.$$" "$cache" || rm -f "$cache.$$" ) </dev/null >/dev/null 2>&1 &
        disown 2>/dev/null || true
    else
        local out
        out="$(scan_candidates)"
        printf '%s\n' "$out"
        mkdir -p "$cache_dir" && printf '%s\n' "$out" >"$cache" 2>/dev/null || true
    fi
}

# Emit "title<TAB>has_custom<TAB>cwd<TAB>ws_id<TAB>win_id" for every open workspace
open_workspaces() {
    local wins win
    wins="$(cmux list-windows --json 2>/dev/null | jq -r '.[].id')" || return 0
    while IFS= read -r win; do
        [[ -n "$win" ]] || continue
        cmux workspace list --json --id-format both --window "$win" 2>/dev/null |
            jq -r --arg w "$win" '.workspaces[] | [(.custom_title // ""), (.has_custom_title|tostring), (.current_directory // ""), .id, $w] | @tsv'
    done <<<"$wins"
}

# --list: emit "name<TAB>path<TAB>ws_id<TAB>win_id" for external pickers
# (Hammerspoon, Raycast). ws_id/win_id are set when a matching workspace is
# already open, so pickers can switch with a single --select call.
if [[ "${1:-}" == "--list" ]]; then
    {
        open_workspaces | sed 's/^/WS\t/'
        {
            # project-configured dirs first so their custom names win the dedupe
            for f in "$PROJECTS_DIR"/*.json; do
                [[ -e "$f" ]] || continue
                dir="$(jq -r '.dir // empty' "$f")"
                [[ -n "$dir" ]] || continue
                dir="$(expand_path "$dir")"
                [[ -d "$dir" ]] || continue
                dir="$(cd "$dir" && pwd -P)"
                printf '%s\t%s\n' "$(jq -r --arg fb "$(basename "$dir" | tr . _)" '.name // $fb' "$f")" "$dir"
            done
            while IFS= read -r dir; do
                [[ -d "$dir" ]] && printf '%s\t%s\n' "$(basename "$dir" | tr . _)" "$dir"
            done < <(candidates)
        } | awk -F'\t' '!seen[$2]++' | sed 's/^/DIR\t/'
    } | awk -F'\t' '
        $1 == "WS" {
            if ($3 == "true") byTitle[$2] = $5 "\t" $6
            else if ($4 != "") byCwd[$4] = $5 "\t" $6
            next
        }
        $1 == "DIR" {
            ws = (($2 in byTitle) ? byTitle[$2] : (($3 in byCwd) ? byCwd[$3] : "\t"))
            print $2 "\t" $3 "\t" ws
        }'
    exit 0
fi

# --select <ws-id> [win-id]: fast path for pickers when the workspace is open
if [[ "${1:-}" == "--select" ]]; then
    [[ -n "${2:-}" ]] || die "--select needs a workspace id"
    cmux workspace select "$2" >/dev/null &
    [[ -n "${3:-}" ]] && cmux focus-window --window "$3" >/dev/null &
    wait
    exit 0
fi

# --- pick a directory ---
if [[ $# -ge 1 ]]; then
    selected="$(expand_path "$1")"
else
    selected="$(candidates | sed "s|^$HOME/||" | awk '!seen[$0]++' | sk --margin 10% --color="bw")" || true
    [[ -z "${selected:-}" ]] && exit 0
    [[ "$selected" != /* ]] && selected="$HOME/$selected"
fi

[[ -d "$selected" ]] || die "not a directory: $selected"
selected="$(cd "$selected" && pwd -P)"

# --- match against per-project config ---
project_file=""
for f in "$PROJECTS_DIR"/*.json; do
    [[ -e "$f" ]] || continue
    dir="$(jq -r '.dir // empty' "$f")"
    [[ -n "$dir" ]] || continue
    dir="$(expand_path "$dir")"
    [[ -d "$dir" ]] || continue
    if [[ "$(cd "$dir" && pwd -P)" == "$selected" ]]; then
        project_file="$f"
        break
    fi
done

name="$(basename "$selected" | tr . _)"
if [[ -n "$project_file" ]]; then
    name="$(jq -r --arg fallback "$name" '.name // $fallback' "$project_file")"
fi

# --- make sure cmux is up (list-windows doubles as the liveness probe) ---
if ! wins="$(cmux list-windows --json 2>/dev/null)"; then
    open -a cmux || die "cannot launch cmux"
    for _ in $(seq 1 50); do
        wins="$(cmux list-windows --json 2>/dev/null)" && break
        sleep 0.2
    done
    [[ -n "${wins:-}" ]] || die "cmux socket not responding"
fi

# --- switch to an existing workspace if one matches ---
# Match by custom title (set by this script on create), or by cwd for
# workspaces that were never given a custom title.
while IFS= read -r win; do
    ws_id="$(cmux workspace list --json --id-format both --window "$win" | jq -r --arg n "$name" --arg d "$selected" '
        [.workspaces[] | select(
            .custom_title == $n
            or ((.has_custom_title | not) and .current_directory == $d)
        )][0].id // empty')"
    if [[ -n "$ws_id" ]]; then
        cmux workspace select "$ws_id" >/dev/null &
        cmux focus-window --window "$win" >/dev/null &
        wait
        exit 0
    fi
done < <(jq -r '.[].id' <<<"$wins")

# --- create a new workspace ---
args=(workspace create --name "$name" --cwd "$selected" --focus true)

if [[ -n "$project_file" ]]; then
    desc="$(jq -r '.description // empty' "$project_file")"
    [[ -n "$desc" ]] && args+=(--description "$desc")

    layout="$(jq -c '.layout // empty' "$project_file")"
    cmd="$(jq -r '.command // empty' "$project_file")"
    if [[ -n "$layout" ]]; then
        args+=(--layout "$layout")
    elif [[ -n "$cmd" ]]; then
        args+=(--command "$cmd")
    fi

    while IFS= read -r kv; do
        args+=(--env "$kv")
    done < <(jq -r '.env // {} | to_entries[] | "\(.key)=\(.value)"' "$project_file")
fi

cmux "${args[@]}" >/dev/null
