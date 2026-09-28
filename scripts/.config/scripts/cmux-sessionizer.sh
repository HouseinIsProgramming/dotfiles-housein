#!/usr/bin/env bash
set -euo pipefail

# cmux-sessionizer: fuzzy-pick a project directory, then switch to its cmux
# workspace or create one. Per-project layouts/commands/env live in
# ~/.config/cmux-sessionizer/ — nothing is written into project directories.

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/cmux-sessionizer"
CONFIG_FILE="$CONFIG_DIR/config.json"
PROJECTS_DIR="$CONFIG_DIR/projects"
export CMUX_QUIET=1

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

candidates() {
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

# --- make sure cmux is up ---
if ! cmux ping >/dev/null 2>&1; then
    open -a cmux || die "cannot launch cmux"
    for _ in $(seq 1 50); do
        cmux ping >/dev/null 2>&1 && break
        sleep 0.2
    done
    cmux ping >/dev/null 2>&1 || die "cmux socket not responding"
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
        cmux focus-window --window "$win" >/dev/null
        cmux workspace select "$ws_id" >/dev/null
        exit 0
    fi
done < <(cmux list-windows --json | jq -r '.[].id')

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
