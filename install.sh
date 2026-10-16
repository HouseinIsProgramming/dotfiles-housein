#!/usr/bin/env bash
# Set up a new Mac from this repo. Safe to re-run.
# Existing real files in ~ make stow stop with a conflict; move them aside and re-run.
set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
step() { printf '\n==> %s\n' "$*"; }

step "Homebrew"
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle --file="$REPO/Brewfile"

step "Tools installed outside Homebrew"
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash
command -v herdr >/dev/null || curl -fsSL https://herdr.dev/install.sh | sh
command -v hawk >/dev/null || curl -fsSL https://raw.githubusercontent.com/HouseinIsProgramming/hawk-tui/main/install.sh | bash
command -v sherlock >/dev/null || curl -fsSL https://raw.githubusercontent.com/michaelbromley/sherlock/main/install.sh | bash
[ -x ~/.bun/bin/northflank ] || bun add -g @northflank/cli

step "Linking dotfiles"
# Apps that rewrite their config get a folded directory symlink (see README).
mkdir -p ~/.config/gh ~/.config/herdr ~/.config/raycast ~/.local/bin ~/superwhisper
cd "$REPO"
stow zsh zprofile git nvim ghostty prompt karabiner herdr raycast atuin linearmouse gh superwhisper

step "herdr plugins"
herdr plugin install sd2k/thumbs || true

step "Done"
cat <<'EOF'
Next:
  1. gh auth login
  2. Clone ai-config and run its install.sh (Claude Code, Paseo, skills).
  3. Raycast: Settings > Advanced > Import, using the .rayconfig exported on the old Mac.
  4. Open Karabiner-Elements, LinearMouse, superwhisper and grant their permissions.
EOF
