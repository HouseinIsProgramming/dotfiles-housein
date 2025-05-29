function cfzf --wraps='cd "$(dirname "$(fzf)")"' --description 'alias cfzf cd "$(dirname "$(fzf)")"'
  cd "$(dirname "$(fzf)")" $argv
        
end
