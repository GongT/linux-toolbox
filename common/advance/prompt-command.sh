declare -A PROMPT_COMMAND_TITLES
declare -A PROMPT_COMMAND_ACTIONS
function _run-prompt-commands() {
	local IFS=''
	for item in "${PROMPT_COMMAND_ACTIONS[@]}"; do
		eval "$item" >/dev/null
	done
	echo -en '\e]0;'
	if [[ ${#PROMPT_COMMAND_TITLES[@]} -gt 0 ]]; then
		for item in "${PROMPT_COMMAND_TITLES[@]}"; do
			echo -n "$($item)"
		done
		echo -n " :: "
	fi
	echo -n "${_REMOTE_PATH_IN_TITLE} - $(pwd)"
	echo -ne '\007'
}

export -f _run-prompt-commands
if [[ ${PROMPT_COMMAND-} != __vsc_* ]]; then
	export PROMPT_COMMAND="_run-prompt-commands"
fi
