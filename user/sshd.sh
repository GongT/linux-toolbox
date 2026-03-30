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

function __support_base64() {
	local VAR_NAME=$1
	if [[ ${!VAR_NAME+found} != "found" ]]; then
		return
	fi

	local RAW_VALUE=${!VAR_NAME}

	if echo "$RAW_VALUE" | base64 -d &>/dev/null; then
		export "$VAR_NAME=$(echo "$RAW_VALUE" | base64 -d)"
	fi
}

__support_base64 USER_DISPLAYNAME
__support_base64 COMPUTERNAME

unset __support_base64
