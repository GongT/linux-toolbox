declare -xr _systemctl=$(find_command systemctl)
declare -xr _journalctl=$(find_command journalctl)

systemctl() {
	if [[ $UID -eq 0 ]]; then
		"$_systemctl" "$@"
	elif [[ $* == *"--system"* ]]; then
		$SUDO "$_systemctl" "$@"
	elif [[ $* == *"--user"* ]]; then
		"$_systemctl" "$@"
	else
		"$_systemctl" --user "$@"
	fi
}
journalctl() {
	if [[ $UID -eq 0 ]]; then
		"$_journalctl" "$@"
	elif [[ $* == *"--system"* ]]; then
		$SUDO "$_journalctl" "$@"
	elif [[ $* == *"--user"* ]]; then
		"$_journalctl" "$@"
	else
		"$_journalctl" --user "$@"
	fi
}
