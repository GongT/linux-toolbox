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

if [[ ${USER_DISPLAYNAME-} ]]; then
	if ! echo "$USER_DISPLAYNAME" | iconv -f UTF-8 &>/dev/null ; then
		USER_DISPLAYNAME=$(echo "$USER_DISPLAYNAME" | iconv -f GB18030 -t UTF-8)

		if [[ -t 2 ]]; then
			printf "\e[38;5;11m%s\e[0m\n" "warning: USER_DISPLAYNAME is not valid UTF-8, assuming it uses GB18030: '$USER_DISPLAYNAME'" >&2
		fi
	fi

	export USER_DISPLAYNAME
fi
