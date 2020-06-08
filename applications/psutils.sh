if ! command_exists killall ; then
	return 0
fi

emit "alias killall=\"$(find_command killall) --verbose --wait --ns \$\$ \""
