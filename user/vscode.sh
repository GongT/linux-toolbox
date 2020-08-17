if command -v run-windows &>/dev/null ; then
	if run-windows command_exists code.cmd ; then
		alias code="run-cygpath code.cmd"
	elif run-windows command_exists code-insiders.cmd ; then
		alias code="run-cygpath code-insiders.cmd"
	fi
elif [[ "$VSCODE_SERVER_HACK_ROOT" ]] || [[ "$PATH" =~ "/.vscode-server" ]]; then
	proxy on
	if command_exists code-insiders ; then
		P=$(find_command code-insiders)
		if ! [[ -f "$(dirname "$P")/code" ]]; then
			ln -s code-insiders "$(dirname "$P")/code"
		fi
		unset P
	fi
fi
