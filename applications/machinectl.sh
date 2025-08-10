if command_exists machinectl; then
	MACHINECTL=$(find_command machinectl)
	warp_bin_with_env machinectl bin/machinectl_wrap.sh \
		"MACHINECTL=${MACHINECTL}"
fi
