if command_exists machinectl; then
	MACHINECTL=$(find_command machinectl)
	copy_bin bin/machinectl_wrap.sh machinectl \
		"MACHINECTL=${MACHINECTL}"
fi
