# dotfiles

Mac dotfiles, one [GNU Stow](https://www.gnu.org/software/stow/) package per app.
Each package mirrors `$HOME`, so `nvim/.config/nvim` links to `~/.config/nvim`.
`.stowrc` sets the target to `~`, so the repo can live anywhere (currently `~/Developer/dotfiles`).

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
| `zsh` | zsh (zinit, aliases, abbreviations) | not yet |
| `ghostty`, `tmux`, `prompt`, `scripts` | terminal, tmux, oh-my-posh/starship, helper scripts | not yet |
| `aerospace`, `alacritty`, `fish`, `helix`, `kmonad`, `vim`, `yazi`, `zed`, `cmux-sessionizer`, `lua` | older configs, kept for reference | no |

Claude Code and Codex config live in the `ai-config` repo.

## Notes

- `karabiner` must be stowed as a folded directory (`~/.config/karabiner` itself is the
  symlink): Karabiner replaces `karabiner.json` when it saves, which would break a file symlink.
- `herdr` and `raycast` link into real `~/.config/herdr` / `~/.config/raycast` directories,
  because those apps keep runtime state (logs, sockets, extensions) there.
