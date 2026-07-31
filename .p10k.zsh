# powerlevel10k config reproducing the oh-my-posh "zen" prompt.
#
# Layout (matches zen.json / zen-light.json):
#   <blank line>
#   <path, bold>  <branch> <↑ahead ↓behind> <changed> <staged> <stashes>   [versions, right]
#   $
#
# Palettes are taken verbatim from the two oh-my-posh themes; the light/dark
# choice happens in .zshrc and arrives here as $_ZEN_VARIANT.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # ---- palette (from the oh-my-posh themes) ----------------------------
  # These must be globals, not locals: my_git_formatter below is called at
  # prompt-render time, long after this setup function has returned.
  if [[ ${_ZEN_VARIANT:-zen} == zen-light ]]; then
    typeset -g _zen_red='#cc3768'     _zen_pistachio='#598030' _zen_green='#22478e'
    typeset -g _zen_yellow='#b6662d'  _zen_blue='#22478e'      _zen_celeste='#3f83a6'
    typeset -g _zen_skyblue='#22478e' _zen_white='#262a3f'     _zen_magenta='#6845ad'
    typeset -g _zen_black='#33374c'
  else
    typeset -g _zen_red='#f7768e'     _zen_pistachio='#9ece6a' _zen_green='#73daca'
    typeset -g _zen_yellow='#e0af68'  _zen_blue='#7aa2f7'      _zen_celeste='#b4f9f8'
    typeset -g _zen_skyblue='#7dcfff' _zen_white='#c0caf5'     _zen_magenta='#bb9af7'
    typeset -g _zen_black='#414868'
  fi
  local red=$_zen_red pistachio=$_zen_pistachio green=$_zen_green
  local yellow=$_zen_yellow blue=$_zen_blue celeste=$_zen_celeste
  local skyblue=$_zen_skyblue white=$_zen_white magenta=$_zen_magenta
  local black=$_zen_black

  # ---- layout ---------------------------------------------------------
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs status newline prompt_char)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
      node_version php_version virtualenv pyenv rbenv go_version)

  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true          # the leading blank line
  typeset -g POWERLEVEL9K_BACKGROUND=                      # transparent, like style:plain
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  # Draw the prompt immediately, filling in git state when it arrives.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always          # matches zen's transient_prompt

  # ---- dir: bold, unique-shortened, depth 2 ---------------------------
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$blue
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$blue
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$blue

  # ---- prompt char: green "$" ------------------------------------------
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$pistachio
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$red
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_{VIINS,VICMD,VIVIS,VIOWR}_CONTENT_EXPANSION='$'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  # ---- status: red ✗ on failure only -----------------------------------
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$red
  typeset -g POWERLEVEL9K_STATUS_ERROR_CONTENT_EXPANSION=''
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=$red
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_CONTENT_EXPANSION=''
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=$red
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_CONTENT_EXPANSION=''

  # ---- git -------------------------------------------------------------
  # Reproduces zen's template:
  #   <branch>  ↑ahead ↓behind   ?untracked ~modified -deleted   staged   stashes
  function my_git_formatter() {
    emulate -L zsh -o extended_glob
    if [[ -n $P9K_CONTENT ]]; then       # up-to-date cached value from gitstatus
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi

    local out
    # upstream-less branches get no icon, matching .UpstreamIcon being empty
    local branch=${VCS_STATUS_LOCAL_BRANCH:-${VCS_STATUS_COMMIT[1,8]}}
    out+="%F{$_zen_celeste} ${branch//\%/%%}%f"

    (( VCS_STATUS_COMMITS_AHEAD ))  && out+=" %F{$_zen_green}↑${VCS_STATUS_COMMITS_AHEAD}%f"
    (( VCS_STATUS_COMMITS_BEHIND )) && out+=" %F{$_zen_red}↓${VCS_STATUS_COMMITS_BEHIND}%f"

    # working tree: ?untracked ~modified -deleted
    local -a work
    (( VCS_STATUS_NUM_UNTRACKED )) && work+="?${VCS_STATUS_NUM_UNTRACKED}"
    local modified=$(( VCS_STATUS_NUM_UNSTAGED - VCS_STATUS_NUM_UNSTAGED_DELETED ))
    (( modified > 0 )) && work+="~${modified}"
    (( VCS_STATUS_NUM_UNSTAGED_DELETED )) && work+="-${VCS_STATUS_NUM_UNSTAGED_DELETED}"
    (( $#work )) && out+=" %F{$_zen_yellow} ${(j: :)work}%f"

    (( VCS_STATUS_NUM_STAGED )) && {
        (( $#work )) && out+=" |"
        out+=" %F{$_zen_green} ${VCS_STATUS_NUM_STAGED}%f"
    }
    (( VCS_STATUS_NUM_CONFLICTED )) && out+=" %F{$_zen_red}~${VCS_STATUS_NUM_CONFLICTED}%f"
    (( VCS_STATUS_STASHES )) && out+=" %F{$_zen_black} ${VCS_STATUS_STASHES}%f"

    typeset -g my_git_format=$out
  }
  functions -M my_git_formatter 2>/dev/null

  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter()))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=$white
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1

  # ---- right-hand version segments -------------------------------------
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=$pistachio
  typeset -g POWERLEVEL9K_NODE_VERSION_CONTENT_EXPANSION=' ${P9K_CONTENT}'
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true

  typeset -g POWERLEVEL9K_PHP_VERSION_FOREGROUND=$blue
  typeset -g POWERLEVEL9K_PHP_VERSION_CONTENT_EXPANSION=' ${P9K_CONTENT}'
  typeset -g POWERLEVEL9K_PHP_VERSION_PROJECT_ONLY=true

  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$yellow
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=
  typeset -g POWERLEVEL9K_VIRTUALENV_CONTENT_EXPANSION=' ${P9K_CONTENT}'

  typeset -g POWERLEVEL9K_PYENV_FOREGROUND=$yellow
  typeset -g POWERLEVEL9K_PYENV_CONTENT_EXPANSION=' ${P9K_CONTENT}'
  typeset -g POWERLEVEL9K_PYENV_SOURCES=(shell local)
  typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false

  typeset -g POWERLEVEL9K_RBENV_FOREGROUND=$red
  typeset -g POWERLEVEL9K_RBENV_CONTENT_EXPANSION=' ${P9K_CONTENT}'
  typeset -g POWERLEVEL9K_RBENV_SOURCES=(shell local)
  typeset -g POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW=false

  typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=$skyblue
  typeset -g POWERLEVEL9K_GO_VERSION_CONTENT_EXPANSION=' ${P9K_CONTENT}'
  typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=true

  (( ! $+functions[p10k] )) || p10k reload
}

(( ${#p10k_config_opts} )) && 'builtin' 'setopt' "${p10k_config_opts[@]}"
'builtin' 'unset' 'p10k_config_opts'
