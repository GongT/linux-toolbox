if [[ "$USERNAME" ]]; then
	echo "Detected VSCode session; USERNAME=$USERNAME; SSH process PID is $$" >&2
	unset USERNAME

	if [[ "$PROXY" ]]; then
		export http_proxy="$PROXY" https_proxy="$PROXY"
		echo "Using proxy: $PROXY" >&2
	fi

	declare -xr VSCODE_SERVER_HACK_ROOT=/data/AppData/VSCodeRemote

	mkdir -p "$VSCODE_SERVER_HACK_ROOT"

	function bash() {
		set -x
		systemd-run --pipe --quiet --wait --collect \
			--property="BindPaths=$VSCODE_SERVER_HACK_ROOT:$HOME/.vscode-server-insiders" \
			--property="BindPaths=$VSCODE_SERVER_HACK_ROOT:$HOME/.vscode-server" \
			/usr/bin/bash -x
	}
fi
