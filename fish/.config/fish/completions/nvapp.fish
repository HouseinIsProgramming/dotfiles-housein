function _should_complete_nvapp_name
	set --local tokens (commandline -poc)
	set --local position 0

	for token in $tokens
		switch $token
			case --
				return 1
			case -b --binary
				set position (math $position - 1)
			case '-*' '--*'
				continue
			case '*'
				set position (math $position + 1)
		end
	end

	return (test $position -eq 1)
end

function _completions_nvim_binaries
	set --local nvim_varriants neovide nvim nvim-qt nvim-x11 gonvim fvim
	for varriant in $nvim_varriants
		if type --query $varriant
			printf "$varriant\t$(which $varriant)\n"
		end
	end
end

complete \
	--command nvapp \
	--condition _should_complete_nvapp_name \
	--no-files \
	--arguments '(_find_nvapp_names)' \
	--description 'Neovim config name'

complete \
	--command nvapp \
	--short-option h \
	--long-option help \
	--no-files \
	--description 'Display this help'

complete \
	--command nvapp \
	--short-option c \
	--long-option clean \
	--no-files \
	--description 'Clean installation files for <nvapp_name>'

complete \
	--command nvapp \
	--short-option d \
	--long-option delete \
	--no-files \
	--description 'Delete configuration directory for <nvapp_name>'

complete \
	--command nvapp \
	--short-option b \
	--long-option binary \
	--no-files \
	--require-parameter \
	--arguments '(_completions_nvim_binaries)' \
	--description 'Specify Neovim binary to use'
