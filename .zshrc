#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#
# Single-file interactive config. Load order matters and is grouped below:
#   env -> fpath -> zinit+plugins -> compinit -> completion UI -> tool init
#   -> keybinds -> aliases -> functions
# Tool `init` output is cached by cached_eval (see below) to avoid a fork per
# shell; caches self-invalidate when the binary is newer than the cache.

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"

export LUA_PATH="$HOME/.luarocks/share/lua/5.1/?.lua;;"
export LUA_CPATH="$HOME/.luarocks/lib/lua/5.1/?.so;;"
export LEDGER_FILE="$HOME/Documents/GitHub/Claude/finances/finances.journal"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/Library/pnpm"

# brew shellenv also runs in ~/.zprofile; skip the fork when already applied.
if [[ -z $HOMEBREW_PREFIX && -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# path is declared unique in ~/.zshenv, so re-adding an entry is a no-op.
path=(
    $HOME/.local/bin
    $HOME/.cargo/bin
    $HOME/.atuin/bin
    $HOME/go/bin
    $HOME/.local/opt/go/bin
    $BUN_INSTALL/bin
    $PNPM_HOME
    $HOME/.maestro/bin
    $HOME/.antigravity/antigravity/bin
    $HOME/.claude/skills/arnold
    $HOME/dotfiles-housein/.config/scripts
    /opt/homebrew/opt/postgresql@15/bin
    /Applications/WebStorm.app/Contents/MacOS
    $path
)

# ---------------------------------------------------------------------------
# fpath — every addition must happen before compinit
# ---------------------------------------------------------------------------
fpath=(
    $HOME/.config/zshrc/completion_zsh
    $HOME/.zsh/completions                                   # deno
    $HOME/.local/share/zinit/plugins/zsh-users---zsh-completions/src
    $fpath
)

# ---------------------------------------------------------------------------
# Plugins (zinit)
# ---------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
    print -P "%F{33}Installing zinit…%f"
    command mkdir -p "${ZINIT_HOME:h}"
    command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit

# Deferred: none of these are needed before the first prompt.
zinit ice wait lucid; zinit light zsh-users/zsh-autosuggestions
zinit ice wait lucid; zinit light zsh-users/zsh-syntax-highlighting
zinit ice wait lucid; zinit light joknarf/redo
zinit ice wait lucid; zinit light joknarf/seedee
zinit ice wait lucid; zinit light lukechilds/zsh-nvm

# ---------------------------------------------------------------------------
# Completion
# ---------------------------------------------------------------------------
autoload -Uz compinit
_zcompdump=${ZDOTDIR:-$HOME}/.zcompdump
if [[ -n $_zcompdump(#qN.mh+24) ]]; then
    compinit -d $_zcompdump
    touch $_zcompdump          # compinit leaves mtime alone when the dump is unchanged
else
    compinit -C -d $_zcompdump
fi
# Compile the dump in the background; a compiled dump loads far faster and this
# is what keeps a missing/stale dump from costing ~280ms on the next shell.
# zcompile writes .zwc read-only, so build a temp file and move it into place —
# overwriting directly fails, and the move also makes concurrent shells safe.
if [[ ! -s $_zcompdump.zwc || $_zcompdump -nt $_zcompdump.zwc ]]; then
    {
        # zcompile appends .zwc unless the name already ends in it, so name the
        # temp file accordingly or the move below finds nothing.
        _t=$_zcompdump.$$.zwc
        zcompile -R $_t $_zcompdump 2>/dev/null && command mv -f $_t $_zcompdump.zwc 2>/dev/null
        [[ -e $_t ]] && command rm -f $_t
    } &!
fi
unset _zcompdump

zinit light Aloxaf/fzf-tab                                   # must follow compinit

# ---------------------------------------------------------------------------
# Cached tool initialisation
# ---------------------------------------------------------------------------
# cached_eval <cache-name> <command...> — run <command> once, keep its output,
# source that on later shells. Rebuilds when the binary outdates the cache.
cached_eval() {
    local name=$1; shift
    local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init-$name.zsh"
    local bin=${commands[$1]:-$1}
    if [[ ! -s $cache || ( -n $bin && $bin -nt $cache ) ]]; then
        mkdir -p ${cache:h}
        "$@" > $cache 2>/dev/null || { rm -f $cache; return 1 }
        zcompile -R $cache 2>/dev/null
    fi
    source $cache
}

# Prompt. The light/dark choice is baked into the cache name so switching
# appearance picks up the other cache instead of re-running `defaults read`.
if [[ -n ${_omp_dark::=$(defaults read -g AppleInterfaceStyle 2>/dev/null)} ]]; then
    _omp_variant=zen
else
    _omp_variant=zen-light
fi
cached_eval "omp-$_omp_variant" oh-my-posh init zsh --config "$HOME/.config/omp-themes/$_omp_variant.json"
unset _omp_dark _omp_variant

cached_eval fzf    fzf --zsh
cached_eval atuin  atuin init zsh
cached_eval direnv direnv hook zsh
cached_eval zoxide zoxide init zsh --cmd j                   # provides j / ji

[[ -r $HOME/.opam/opam-init/init.zsh ]] && source $HOME/.opam/opam-init/init.zsh >/dev/null 2>&1
[[ -s $HOME/.bun/_bun ]] && source $HOME/.bun/_bun
[[ -f $HOME/.nx-completion/nx-completion.plugin.zsh ]] && source $HOME/.nx-completion/nx-completion.plugin.zsh
[[ -f $HOME/.openclaw/completions/openclaw.zsh ]] && source $HOME/.openclaw/completions/openclaw.zsh

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE
setopt sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# ---------------------------------------------------------------------------
# Keybinds — bindkey -e resets everything, so it comes first
# ---------------------------------------------------------------------------
bindkey -e

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

zinit light momo-lab/zsh-abbrev-alias                        # must follow bindkey -e

bindkey -r '^h'
bindkey -r '^l'
bindkey '^h' backward-word
bindkey '^l' forward-word
bindkey '^j' forward-word                                    # accept a word from autosuggestion

copy-line-to-clipboard() { print -rn -- "$BUFFER" | pbcopy }
zle -N copy-line-to-clipboard
bindkey '^x^l' copy-line-to-clipboard

fzf-npm-script() {
    local script
    script=$(node -e 'console.log(Object.keys(require("./package.json").scripts || {}).join("\n"))' 2>/dev/null | fzf) || return
    LBUFFER+="npm run $script"
    zle redisplay
}
zle -N fzf-npm-script
bindkey '^[n' fzf-npm-script                                 # alt+n

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias c='clear'
alias ff='fastfetch'
alias ll='eza -al --icons=always'
alias v='nvim'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias lg='lazygit'
alias ldkr='lazydocker'
alias fdd='cd "$(fd -t d . | fzf --preview "dirname {}")"'
alias fdf='cd "$(fzf --preview "bat --style=numbers --color=always {}" | xargs dirname)"'
alias ..='j ..'
alias ...='j ../..'
alias ....='j ../../..'
alias fett='open -g "raycast://script-commands/confetti-burst"'
alias sherlock="$HOME/.claude/skills/sherlock/sherlock"
alias pico='cd "$HOME/Library/Application Support/pico-8/carts"'
alias sshosts='grep "^Host " ~/.ssh/config'
alias claudemd='nvim ~/.claude/claude.md'
alias claude='CLAUDE_CODE_NO_FLICKER=1 claude'
alias remind='remindctl show upcoming'

# Abbreviations — expand on space/enter so history keeps the real command.
abbrev-alias lt="eza -a --tree --icons=always --level="
abbrev-alias pwdc="pwd|pbcopy && pwd"
abbrev-alias ta="tmux a"
abbrev-alias cl="claude"
abbrev-alias cld="claude --dangerously-skip-permissions"
abbrev-alias cle="claude --model haiku -p"
abbrev-alias luj="luajit"
abbrev-alias hl="arch -x86_64 /usr/local/bin/hl"
abbrev-alias npv="npm run dev"
abbrev-alias npd="npm run build"
abbrev-alias nps="npm run start"
abbrev-alias npw="npm run watch"
abbrev-alias pm="pnpm"
abbrev-alias pmd="pnpm dlx"
abbrev-alias pmr="pnpm run"
abbrev-alias pmv="pnpm run dev"
abbrev-alias pmb="pnpm run build"
abbrev-alias grs="git restore --staged"
abbrev-alias gs="git status"
abbrev-alias gss="git status -s"
abbrev-alias gcnv="git commit --no-verify -m"
abbrev-alias gc="git commit -m"
abbrev-alias gp="git push"
abbrev-alias gl="git pull"
abbrev-alias gd="git diff"
abbrev-alias gds="git diff --staged"
abbrev-alias gsw="git switch"
abbrev-alias ga="git add"
abbrev-alias glo="git log --oneline"
abbrev-alias dk="docker"
abbrev-alias dkc="docker compose"

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------
# yazi wrapper: cd to wherever yazi left off
i() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# cd to the enclosing git project root
cpr() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        [[ -e "$dir/.git" ]] && { j "$dir"; return 0 }
        dir="${dir:h}"
    done
    print -u2 "No project root found"
    return 1
}

# ---------------------------------------------------------------------------
# Local overrides, kept last so they win
# ---------------------------------------------------------------------------
[[ -f ~/.zshrc_custom ]] && source ~/.zshrc_custom
