if ! [[ -f /etc/ssh/sshd_config ]]; then
	return
fi

if [[ ${SSH_CLIENT+found} == "found" ]]; then
	export SSH_CLIENT_IP=$(echo "${SSH_CLIENT}" | awk '{print $1}')
	if [[ ! ${DISPLAY-} ]]; then
		export DISPLAY="${SSH_CLIENT_IP}:0"
	fi
elif [[ ! ${DISPLAY:-} ]]; then
	export DISPLAY=":0"
fi
