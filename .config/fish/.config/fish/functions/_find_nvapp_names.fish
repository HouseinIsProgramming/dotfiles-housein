function _find_nvapp_names
	set --query XDG_CONFIG_HOME
	set --local XDG_CONFIG_HOME $HOME/.config
	find -L "$XDG_CONFIG_HOME" -maxdepth 2 -name "init.lua" -type f \
		| xargs -I {} dirname {} \
		| xargs -n 1 basename
end
