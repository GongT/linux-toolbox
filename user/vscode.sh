if command -v run-windows &>/dev/null; then
	if run-windows command_exists code.cmd; then
		alias code="run-cygpath code.cmd"
		export EDITOR='run-cygpath code.cmd --wait'
	elif run-windows command_exists code-insiders.cmd; then
		alias code="run-cygpath code-insiders.cmd"
		export EDITOR='run-cygpath code-insiders.cmd --wait'
	fi
elif [[ ${VSCODE_SERVER_HACK_ROOT+found} == found ]] || [[ $PATH =~ "/.vscode-server" ]]; then
	proxy on
	if command_exists code-insiders; then
		P=$(find_command code-insiders)
		if ! [[ -f "$(dirname "$P")/code" ]]; then
			ln -s code-insiders "$(dirname "$P")/code"
		fi
		unset P
	fi
	export EDITOR='code --wait'
elif [[ "$DISPLAY" ]]; then
	if command_exists code-insiders; then
		export EDITOR='code-insiders --wait'
	elif command_exists code; then
		export EDITOR='code --wait'
	fi
fi
