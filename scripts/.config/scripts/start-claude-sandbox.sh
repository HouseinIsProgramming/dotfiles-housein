#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
CONTAINER_CLAUDE="/home/agent/.claude"

# Create temp files/dirs (so container can write without affecting host)
CREDS_TEMP=$(mktemp)
CONFIG_TEMP=$(mktemp)
PLUGINS_TEMP=$(mktemp -d)
PROJECTS_TEMP=$(mktemp -d)
trap "rm -rf '$CREDS_TEMP' '$CONFIG_TEMP' '$PLUGINS_TEMP' '$PROJECTS_TEMP'" EXIT

# Copy .claude.json so container can modify its own copy
cp "${HOME}/.claude.json" "$CONFIG_TEMP" 2>/dev/null || echo '{"numStartups":1}' > "$CONFIG_TEMP"

# Copy plugin config files AND cache (actual plugin code)
if [[ -d "${CLAUDE_DIR}/plugins" ]]; then
    # Copy and fix paths in known_marketplaces.json
    if [[ -f "${CLAUDE_DIR}/plugins/known_marketplaces.json" ]]; then
        sed "s|${CLAUDE_DIR}|${CONTAINER_CLAUDE}|g" \
            "${CLAUDE_DIR}/plugins/known_marketplaces.json" > "$PLUGINS_TEMP/known_marketplaces.json"
    fi
    # Copy and fix paths in installed_plugins.json (host paths -> container paths)
    if [[ -f "${CLAUDE_DIR}/plugins/installed_plugins.json" ]]; then
        sed "s|${CLAUDE_DIR}|${CONTAINER_CLAUDE}|g; s|/home/automaker/.claude|${CONTAINER_CLAUDE}|g" \
            "${CLAUDE_DIR}/plugins/installed_plugins.json" > "$PLUGINS_TEMP/installed_plugins.json"
    fi
    # Copy plugin cache (installed plugin code)
    if [[ -d "${CLAUDE_DIR}/plugins/cache" ]]; then
        cp -r "${CLAUDE_DIR}/plugins/cache" "$PLUGINS_TEMP/"
    fi
    # Copy marketplaces (plugin source repos for discovery/installation)
    if [[ -d "${CLAUDE_DIR}/plugins/marketplaces" ]]; then
        cp -r "${CLAUDE_DIR}/plugins/marketplaces" "$PLUGINS_TEMP/"
    fi
fi

# Extract credentials from macOS Keychain
if security find-generic-password -s "Claude Code-credentials" -w > "$CREDS_TEMP" 2>/dev/null; then
    echo "✓ Found credentials in macOS Keychain"
else
    echo "✗ No credentials in Keychain. Run 'claude' on host first to authenticate."
    exit 1
fi

VOLUME_ARGS=(
    # Credentials from Keychain (read-only)
    "-v" "${CREDS_TEMP}:${CONTAINER_CLAUDE}/.credentials.json:ro"
    # Onboarding/setup marker file (copy, so container can write)
    "-v" "${CONFIG_TEMP}:/home/agent/.claude.json"
    # Plugins directory with cache (copy, so plugins load and can be managed)
    "-v" "${PLUGINS_TEMP}:${CONTAINER_CLAUDE}/plugins"
    # Projects directory (writable temp, for session files)
    "-v" "${PROJECTS_TEMP}:${CONTAINER_CLAUDE}/projects"
)

# Config files to mount (read-only)
CONFIG_FILES=(
    "settings.json"
    "CLAUDE.md"
    "hooks"
    "commands"
    "skills"
    "statsig"
)

for item in "${CONFIG_FILES[@]}"; do
    src="${CLAUDE_DIR}/${item}"

    if [[ -L "$src" ]]; then
        target=$(readlink -f "$src")
        [[ -e "$target" ]] && VOLUME_ARGS+=("-v" "${target}:${CONTAINER_CLAUDE}/${item}:ro")
    elif [[ -e "$src" ]]; then
        VOLUME_ARGS+=("-v" "${src}:${CONTAINER_CLAUDE}/${item}:ro")
    fi
done

exec docker sandbox run "${VOLUME_ARGS[@]}" claude "$@"
