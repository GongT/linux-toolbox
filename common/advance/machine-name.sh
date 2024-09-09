function set-prompt() {
	local VAL=$1

	if [[ "$VAL" ]]; then
		envfile-user PROMPT_VALUE "$VAL"
	else
		if [[ "${PROMPT_VALUE+found}" ]]; then
			VAL="$PROMPT_VALUE"
		elif [[ "${MACHINE_NAME+found}" ]]; then
			VAL="$MACHINE_NAME"
			envfile-user PROMPT_VALUE "$VAL"
		else
			VAL="$(hostname)"
			envfile-user PROMPT_VALUE "$VAL"
		fi
	fi

	if [[ $SHELL != "/bin/bash" ]]; then
		export PS1="${VAL}${ENDING}"
	elif is_root; then
		export PS1="[\[\e[38;5;${CUSTOM_PROMPT_COLOR-9}m\]$VAL\[\e[0m\] \W]# "
	else
		export PS1="[\[\e[38;5;${CUSTOM_PROMPT_COLOR-10}m\]\u@$VAL\[\e[0m\] \W]$ "
	fi
}
function set-prompt-color() {
	declare -gi CUSTOM_PROMPT_COLOR
	CUSTOM_PROMPT_COLOR="$1"
	envfile-user CUSTOM_PROMPT_COLOR "$CUSTOM_PROMPT_COLOR"
	set-prompt ''
}
function set-machine-name() {
	envfile-user MACHINE_NAME "$1"
	___calc_REMOTE_PATH
	export MACHINE_NAME="$1"
	set-prompt ''
}
function ___calc_REMOTE_PATH() {
	local M="${MACHINE_NAME-$(hostname)}"
	if [[ ${REMOTE_PATH+found} == 'found' ]]; then
		REMOTE_PATH+=":$M"
	else
		export REMOTE_PATH="$M"
	fi
	if [[ ! ${SSH_ORIGIN_MACHINE} ]]; then
		export SSH_ORIGIN_MACHINE="$M"
	fi
	export _REMOTE_PATH_IN_TITLE=$(echo "$REMOTE_PATH" | sed 's/:/ → /g')
}

___calc_REMOTE_PATH
set-prompt ''
