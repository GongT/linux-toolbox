if command_exists machinectl; then
	MACHINECTL=$(find_command machinectl)
	emit "alias machinectl=\"${VAR_HERE}/bin/machinectl_wrap.sh '${MACHINECTL}'\""
fi
