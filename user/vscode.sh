# this file run each bash session
__check_vscode() {
	local VSCODE_BIN
	if command -v run-windows &>/dev/null; then
		if run-windows command_exists code.cmd; then
			alias code="run-cygpath code.cmd"
			export EDITOR='run-cygpath code.cmd --wait'
		elif run-windows command_exists code-insiders.cmd; then
			alias code="run-cygpath code-insiders.cmd"
			export EDITOR='run-cygpath code-insiders.cmd --wait'
		fi
		return
	elif [[ $VSCODE_IPC_HOOK_CLI ]]; then
		# vscode-remote itegrated terminal
		VSCODE_BIN=$(command -v code-insiders || command -v code) 2>/dev/null

		if ! echo "$VSCODE_BIN" | grep -qiE '[0-9a-f]{40}'; then
			echo "missing valid vscode executable in PATH" >&2
			return
		fi
	elif [[ -d $VSCODE_CWD ]]; then
		# hooked vscode-remote terminal -> ssh -> localhost or another hooked host
		cd "$VSCODE_CWD"
		if [[ $SSH_CLIENT != "::1 "* && $SSH_CLIENT != "127.0.0.1 "* ]] || ! [[ -d $VSCODE_AGENT_FOLDER ]]; then
			return
		fi

		local CURR_VER
		CURR_VER=$(jq -r '.[0]' <"$VSCODE_AGENT_FOLDER/cli/servers/lru.json" 2>/dev/null)
		VSCODE_BIN="$VSCODE_AGENT_FOLDER/cli/servers/$CURR_VER/server/bin/remote-cli"

		if [[ -e "$VSCODE_BIN/code-insiders" ]]; then
			VSCODE_BIN+="/code-insiders"
		elif [[ -e "$VSCODE_BIN/code" ]]; then
			VSCODE_BIN+="/code"
		else
			return
		fi
	elif [[ $TERM_PROGRAM == 'vscode' ]]; then
		# locally installed vscode itegrated terminal
		VSCODE_BIN=$(command -v code-insiders || command -v code) 2>/dev/null

		if ! [[ "$VSCODE_BIN" ]]; then
			# TODO: maybe sudo, then should not alert
			# echo "missing vscode command in PATH" >&2
			return
		fi
	else
		return
	fi

	export EDITOR=$(printf "%q --wait" "$VSCODE_BIN")

	if [[ $(basename "$VSCODE_BIN") == 'code-insiders' ]]; then
		local PARENT=$(dirname "$VSCODE_BIN")
		# if [[ "$PARENT" == /bin ]] || [[ "$PARENT" == /usr/bin ]] || [[ "$PARENT" == /usr/local/bin ]]; then
		# 	return
		# fi
		local LINK="$PARENT/code"

		if [[ -L $LINK ]]; then
			if [[ $(readlink "$LINK") == "./code-insiders" ]]; then
				return
			else
				"${_SUDO[@]}" unlink "$LINK"
			fi
		elif [[ -e $LINK ]]; then
			echo "$LINK is not linked to code-insiders" >&2
			return
		fi

		echo "create $LINK link to code-insiders" >&2
		"${_SUDO[@]}" ln -s "./code-insiders" "$LINK"
	fi
}
__check_vscode
