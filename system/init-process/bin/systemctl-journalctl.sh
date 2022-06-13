declare -xr _systemctl=$(find_command systemctl)
declare -xr _journalctl=$(find_command journalctl)

systemctl() {
	if [[ $* == *"--user"* ]]; then
		"$_systemctl" "$@"
	else
		$SUDO "$_systemctl" "$@"
	fi
}
journalctl() {
	if [[ $* == *"--user"* ]]; then
		"$_journalctl" "$@"
	else
		$SUDO "$_journalctl" "$@"
	fi
}
