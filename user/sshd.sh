if ! [[ -f /etc/ssh/sshd_config ]]; then
	return
fi

function sshd-allow-environment() {
	local VALUES="$*"
	if [[ ! "$VALUES" ]]; then
		echo "Empty input!" >&2
		return 1
	fi
	if grep --fixed-strings "AcceptEnv $VALUES" /etc/ssh/sshd_config &>/dev/null; then
		return
	fi
	echo "AcceptEnv $VALUES" >>/etc/ssh/sshd_config
}

sshd-allow-environment DISPLAY REMOTE_PATH
