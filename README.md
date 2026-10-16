# dotfiles

Mac dotfiles, one [GNU Stow](https://www.gnu.org/software/stow/) package per app.
Each package mirrors `$HOME`, so `nvim/.config/nvim` links to `~/.config/nvim`.
`.stowrc` sets the target to `~`, so the repo can live anywhere (currently `~/Developer/dotfiles`).

## New Mac

```sh
xcode-select --install
git clone https://github.com/HouseinIsProgramming/dotfiles-housein ~/Developer/dotfiles
~/Developer/dotfiles/install.sh
```

`install.sh` installs the `Brewfile` (CLIs, casks, global npm packages), the CLIs that ship their
own installers (claude, herdr, hawk, sherlock, northflank), stows the packages below and installs
herdr plugins. Then follow its printed next steps. Refresh the Brewfile with
`brew bundle dump --file=Brewfile --force --no-vscode` and keep the hand-added casks at the bottom.

## Day to day

```sh
cd ~/Developer/dotfiles
stow nvim karabiner herdr raycast git   # link
stow -R nvim                            # relink after adding files
stow -D nvim                            # unlink
```

## Packages

| Package | What | Stowed on the current Mac |
|---|---|---|
| `nvim` | Neovim (lazy.nvim) | yes |
| `karabiner` | Karabiner-Elements, ported from Omarchy's keyd | yes |
| `herdr` | herdr, Omarchy's default config | yes |
| `raycast` | Raycast script commands (Arc focus-or-back for Slack/Linear) | yes |
| `git` | git config and global ignore | yes |
| `zsh`, `zprofile` | zsh (zinit, aliases, abbreviations), login shell PATH | yes |
| `ghostty`, `prompt` | terminal, oh-my-posh/starship | yes |
| `atuin` | shell history config (the sync key is not tracked) | yes |
| `linearmouse` | LinearMouse | yes |
| `gh` | GitHub CLI `config.yml` only; `hosts.yml` holds the token | yes |
| `superwhisper` | superwhisper settings and modes | yes |
| `tmux`, `scripts` | tmux, helper scripts | no |
| `aerospace`, `alacritty`, `fish`, `helix`, `kmonad`, `vim`, `yazi`, `zed`, `cmux-sessionizer`, `lua` | older configs, kept for reference | no |

Claude Code and Codex config live in the `ai-config` repo.

## Notes

- `karabiner` must be stowed as a folded directory (`~/.config/karabiner` itself is the
  symlink): Karabiner replaces `karabiner.json` when it saves, which would break a file symlink.
- `atuin`, `linearmouse`, `superwhisper/settings` and `superwhisper/modes` are folded for the same reason.
- `herdr` and `raycast` link into real `~/.config/herdr` / `~/.config/raycast` directories,
  because those apps keep runtime state (logs, sockets, extensions) there.
