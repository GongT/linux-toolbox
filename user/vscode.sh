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
		VSCODE_BIN=$(command -v code-insiders || command -v code) 2>/dev/null

		if ! echo "$VSCODE_BIN" | grep -qiE '[0-9a-f]{40}'; then
			echo "missing valid vscode executable in PATH" >&2
			return
		fi
	elif [[ $TERM_PROGRAM == 'vscode' ]]; then
		VSCODE_BIN=$(command -v code-insiders || command -v code) 2>/dev/null

		if ! [[ "$VSCODE_BIN" ]]; then
			echo "missing vscode command in PATH" >&2
			return
		fi
	else
		return
	fi

	export EDITOR=$(printf "%q --wait" "$VSCODE_BIN")

	if [[ $(basename "$VSCODE_BIN") == 'code-insiders' ]]; then
		local PARENT=$(dirname "$VSCODE_BIN")
		local LINK="$PARENT/code"

		if [[ -L $LINK ]]; then
			if [[ $(readlink "$LINK") == "./code-insiders" ]]; then
				return
			else
				unlink "$LINK"
			fi
		elif [[ -e $LINK ]]; then
			echo "$LINK is not linked to code-insiders" >&2
			return
		fi

		ln -s "./code-insiders" "$LINK"
	fi
}
__check_vscode
