# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/housien/.zsh/completions:"* ]]; then export FPATH="/Users/housien/.zsh/completions:$FPATH"; fi
#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#
# -----------------------------------------------------
# ML4W zshrc loader
# -----------------------------------------------------

# DON'T CHANGE THIS FILE

# You can define your custom configuration by adding
# files in ~/.config/zshrc
# or by creating a folder ~/.config/zshrc/custom
# with copies of files from ~/.config/zshrc
# -----------------------------------------------------

# -----------------------------------------------------
# Load modular configarion
# -----------------------------------------------------

for f in ~/.config/zshrc/*; do
    if [ ! -d $f ]; then
        c=`echo $f | sed -e "s=.config/zshrc=.config/zshrc/custom="`
        [[ -f $c ]] && source $c || source $f
    fi
done

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# export NVM_LAZY_LOAD=true
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# -----------------------------------------------------
# Load single customization file (if exists)
# -----------------------------------------------------

if [ -f ~/.zshrc_custom ]; then
    source ~/.zshrc_custom
fi

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
source "$HOME/.cargo/env"
export PATH="$HOME/.local/bin:$PATH"
. "/Users/housien/.deno/env"


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/housien/.opam/opam-init/init.zsh' ]] || source '/Users/housien/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

export LUA_PATH="/Users/housien/.luarocks/share/lua/5.1/?.lua;;"
export LUA_CPATH="/Users/housien/.luarocks/lib/lua/5.1/?.so;;"
