if command -v run-windows &>/dev/null ; then
	if run-windows command_exists code.cmd ; then
		alias code="run-cygpath code.cmd"
	elif run-windows command_exists code-insiders.cmd ; then
		alias code="run-cygpath code-insiders.cmd"
	fi
elif [[ "$PATH" =~ "/.vscode-server" ]]; then
	proxy on
	if command_exists code-insiders && ! command_exists code ; then
		ln -s code-insiders "$(dirname "$(find_command code-insiders)")/code"
	fi
fi
