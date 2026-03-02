declare -xr _systemctl=$(find_command systemctl)
declare -xr _journalctl=$(find_command journalctl)

systemctl() {
	local ARGS=("$@")
	if [[ $UID -eq 0 ]]; then
		"$_systemctl" "${ARGS[@]}"
	elif [[ ${ARGS[*]} == *"--system"* ]]; then
		sudo "$_systemctl" "${ARGS[@]}"
	elif [[ ${ARGS[*]} == *"--user"* ]]; then
		"$_systemctl" "${ARGS[@]}"
	else
		"$_systemctl" --user "${ARGS[@]}"
	fi
}
journalctl() {
	local ARGS=("$@")
	if [[ ${ARGS[*]} != *"--namespace"* ]]; then
		ARGS+=("--namespace=*")
	fi
	if [[ $UID -eq 0 ]]; then
		"$_journalctl" "${ARGS[@]}"
	elif [[ ${ARGS[*]} == *"--system"* ]]; then
		sudo "$_journalctl" "${ARGS[@]}"
	elif [[ ${ARGS[*]} == *"--user"* ]]; then
		"$_journalctl" "${ARGS[@]}"
	else
		"$_journalctl" --user "${ARGS[@]}"
	fi
}
