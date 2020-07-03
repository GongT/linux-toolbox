if [[ "$USERNAME" ]]; then
	echo "Detected VSCode session; USERNAME=$USERNAME; SSH process PID is $$" >&2
	unset USERNAME

	if [[ "$PROXY" ]]; then
		export http_proxy="$PROXY" https_proxy="$PROXY"
		echo "Using proxy: $PROXY" >&2
	fi

	declare -xr VSCODE_SERVER_HACK_ROOT=/data/AppData/VSCodeRemote

	function ns_exec() {
		set -x
		unshare --pid --fork --kill-child --mount-proc --propagation=unchanged "$@"
	}

	function bash() {
		sed "s|export VSCODE_AGENT_FOLDER=|export VSCODE_AGENT_FOLDER=$VSCODE_SERVER_HACK_ROOT # |g" \
			| ns_exec /usr/bin/bash "$@"
	}
fi
