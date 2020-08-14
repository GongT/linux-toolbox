if ! [[ -f /etc/ssh/sshd_config ]]; then
	return
fi

function sshd-allow-environment() {
	local title=$1
	shift
	local VALUES="$*"
	if [[ ! "$VALUES" ]]; then
		echo "Empty input!" >&2
		return 1
	fi
	if grep -q --fixed-strings " # $title" /etc/ssh/sshd_config; then
		sed -i "/ # $title/c\AcceptEnv $VALUES # $title" /etc/ssh/sshd_config
	else
		echo "AcceptEnv $VALUES # $title" >>/etc/ssh/sshd_config
	fi
}

if [[ "${SSH_CLIENT+found}" = "found" ]]; then
	export SSH_CLIENT_IP=$(echo "${SSH_CLIENT}" | awk '{print $1}')
fi

if [[ ! "${DISPLAY}" ]]; then
	export DISPLAY="${SSH_CLIENT_IP}:0"
fi
