oh-my-posh init fish --config '/Users/house/.config/ohmyposh/pragmatic.transparent.omp.toml' | source

# Set maximum number of history entries
set -U fish_history_limit 10000

# Set maximum size of history entries (in characters)
set -U fish_history_max_entries 10000

# Ensure history is enabled
set -U fish_history_enabled 1

set -Ux fish_user_paths /Users/house/scripts/bin $fish_user_paths # adding scripts to path

#default editors exports
export VISUAL=vi
export EDITOR="$VISUAL"

# for FFF to cd on exit
# Fish don't support recursive calls so use f function
function f
    fff $argv
    set -q XDG_CACHE_HOME; or set XDG_CACHE_HOME $HOME/.cache
    cd (cat $XDG_CACHE_HOME/fff/.fff_d)
end

#
# this is so yazi changes directory on quit
#
function zi
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
        clear
        ls -la
    end
    rm -f -- "$tmp"
end

#
# this is so spf changes directory on quit
#



function sp
    set os (uname -s)

    # Decide the location of the "lastdir" file
    if test "$os" = "Linux"
        set -q XDG_STATE_HOME; or set XDG_STATE_HOME "$HOME/.local/state"
        set -gx SPF_LAST_DIR "$XDG_STATE_HOME/superfile/lastdir"
    else if test "$os" = "Darwin"
        set -gx SPF_LAST_DIR "$HOME/Library/Application Support/superfile/lastdir"
    end

    # Launch the actual file manager
    command spf $argv

    # After exit, source the saved script and delete it
    if test -f "$SPF_LAST_DIR"
        source "$SPF_LAST_DIR"
        rm -f "$SPF_LAST_DIR"
    end
end



# FOR PERSISTENT HISTORY 
function save_cd_history --on-variable PWD
    echo $PWD >>$fish_cd_history_file
    # Remove duplicates while keeping the latest entry of each unique directory
    set -l temp (mktemp)
    awk '!seen[$0]++' $fish_cd_history_file >$temp
    mv $temp $fish_cd_history_file
end

#ALIAS
function load_cd_history
    for dir in (cat $fish_cd_history_file)
        echo $dir
    end
end

# BINDS
#
# Bind Ctrl+F to tmux-sessionizer
function __tmux_sessionizer
    tmux-sessionizer
end




# ctrl o to open yazi
# ctrl e to open nvim in the current directory
if not set -q NVIM
    # bind \co 'zi'
    bind \ce 'nvc'
end

# Bind the function to Ctrl+k
bind \ck __tmux_sessionizer

#adding cargo to path
set -gx PATH /Users/house/.cargo/bin $PATH
set -p fish_user_paths "$HOME/.config/emacs/bin" $fish_user_paths

#adding helixSource to Path
export HELIX_RUNTIME=~/src/helix/runtime

#adding npm to path 
export PATH="/opt/homebrew/lib/node_modules/.bin:$PATH"

# adding go to path
# Set GOPATH
set -Ux GOPATH (go env GOPATH)

# Add GOPATH/bin to PATH
set -U fish_user_paths $GOPATH/bin $fish_user_paths

# Created by `pipx` on 2025-03-25 06:53:05
set PATH $PATH /Users/house/.local/bin

# export NVM_DIR="$HOME/.nvm"
#   [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
#   [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

fish_vi_key_bindings
bind -M insert \cf accept-autosuggestion
bind -M insert \cn history-search-backward
bind -M insert \cp  history-search-forward
# if status is-interacti
#     if not set -q ZELLIJ # Check if NOT already inside a Zellij session
#         set -gx ZELLIJ_AUTO_ATTACH true # Set the auto-attach environment variable
#         eval (zellij setup --generate-auto-start fish | string collect)
#     end
# end
#
#
#
#

# export theme setting
# Check if macOS is in dark mode
# set interfaceStyle (defaults read -g AppleInterfaceStyle ^/dev/null)
#
# if test "$interfaceStyle" = "Dark"
#   set -gx TERMINAL_THEME dark
# else
#   set -gx TERMINAL_THEME light
# end

# Added by Windsurf
fish_add_path /Users/house/.codeium/windsurf/bin

string match -q "$TERM_PROGRAM" "kiro" and . (kiro --locate-shell-integration-path fish)
