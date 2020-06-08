if ! command_exists vi ; then
	return 0
fi

emit_alias_sudo2 vi vim
emit_alias_sudo vim


set ignorecase
