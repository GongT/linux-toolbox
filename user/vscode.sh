if [[ "$PATH" =~ "/.vscode-server" ]]; then
	proxy on
	if command_exists code-insiders && ! command_exists code ; then
		ln -s code-insiders "$(dirname "$(find_command code-insiders)")/code"
	fi
fi
