if [[ ! ${SSH_CLIENT_IP+found} && ${SSH_CLIENT+found} ]]; then
	export SSH_CLIENT_IP=$(echo "${SSH_CLIENT}" | awk '{print $1}')
	if [[ ! ${DISPLAY-} ]]; then
		export DISPLAY="${SSH_CLIENT_IP}:0"
	fi
fi

if [[ ! ${DISPLAY:-} ]]; then
	if [[ ${SSH_CLIENT_IP+found} ]]; then
		export DISPLAY="$SSH_CLIENT_IP:0"
	else
		export DISPLAY=":0"
	fi
fi
