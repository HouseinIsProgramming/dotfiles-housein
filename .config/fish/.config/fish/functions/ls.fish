function ls --wraps='eza -lha --sort=size' --description 'alias ls eza -lha --sort=size'
  eza -lha --sort=size $argv
        
end
