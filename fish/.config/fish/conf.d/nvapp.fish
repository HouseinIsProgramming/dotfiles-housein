# fzf.fish is only meant to be used in interactive mode. If not in interactive mode and not in CI, skip the config to speed up shell startup
if not status is-interactive && test "$CI" != true
	exit
end

function _fish_nvim_appname_uninstall --on-event fish_nvim_appname_uninstall
	complete --erase nvapp
	functions --erase nvapp _find_nvapp_names
end
