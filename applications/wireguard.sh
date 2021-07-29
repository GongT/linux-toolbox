if ! command_exists wg ; then
	return 0
fi

emit "alias wg=\"${VAR_HERE}/bin/wg_wrap.sh '$(find_command wg)'\""
