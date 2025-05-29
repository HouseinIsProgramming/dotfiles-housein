function cfzd --wraps='cd "$(fd -t d -L | fzf)"' --description 'alias cfzd cd "$(fd -t d -L | fzf)"'
  cd "$(fd -t d -L | fzf)" $argv
        
end
