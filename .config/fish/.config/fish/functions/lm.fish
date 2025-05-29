function lm --wraps='eza -la --sort=modified' --wraps='eza -lha --sort=modified' --description 'alias lm eza -lha --sort=modified'
  eza -lha --sort=modified $argv
        
end
