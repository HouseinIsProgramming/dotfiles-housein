function cfzr --wraps='cd $(load_cd_history | fzf)' --description 'alias cfzr cd $(load_cd_history | fzf)'
  cd $(load_cd_history | fzf) $argv
        
end
