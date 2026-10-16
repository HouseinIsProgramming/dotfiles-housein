#!/usr/bin/env bash
# Set up a new Mac from this repo. Safe to re-run.
# Existing real files in ~ make stow stop with a conflict; move them aside and re-run.
set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
step() { printf '\n==> %s\n' "$*"; }
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"

step "Homebrew"
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle --file="$REPO/Brewfile" || echo "  some Brewfile entries failed; see above. Continuing."

step "Tools installed outside Homebrew"
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash || true
command -v herdr >/dev/null || curl -fsSL https://herdr.dev/install.sh | sh || true
command -v hawk >/dev/null || curl -fsSL https://raw.githubusercontent.com/HouseinIsProgramming/hawk-tui/main/install.sh | bash || true
command -v sherlock >/dev/null || curl -fsSL https://raw.githubusercontent.com/michaelbromley/sherlock/main/install.sh | bash || true
[ -x ~/.bun/bin/northflank ] || bun add -g @northflank/cli || true

step "Linking dotfiles"
# Apps that rewrite their config get a folded directory symlink (see README).
mkdir -p ~/.config/gh ~/.config/herdr ~/.config/raycast ~/.local/bin ~/superwhisper
cd "$REPO"
for pkg in zsh zprofile git nvim ghostty prompt karabiner herdr raycast atuin linearmouse gh superwhisper; do
  stow "$pkg" || echo "  NOT LINKED: $pkg (move the conflicting file above aside, then: stow $pkg)"
done

step "macOS settings"
# Empty Dock on the right that hides itself
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
defaults write com.apple.dock recent-apps -array
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock orientation -string right
defaults write com.apple.dock autohide -bool true
killall Dock || true
# Fastest key repeat the Keyboard settings sliders allow; takes effect after logging out
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2
# fn does nothing on its own (default opens the emoji picker)
defaults write com.apple.HIToolbox AppleFnUsageType -int 0

step "herdr plugins"
herdr plugin install sd2k/herdr-thumbs --yes || true

step "Done"
cat <<'EOF'
Next:
  1. gh auth login
  2. Clone ai-config and run its install.sh (Claude Code, Paseo, skills).
  3. Raycast: Settings > Advanced > Import, using the .rayconfig exported on the old Mac.
  4. Open Karabiner-Elements, LinearMouse, superwhisper and grant their permissions.
EOF
