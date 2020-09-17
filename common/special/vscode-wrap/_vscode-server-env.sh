if [[ "${VSCODE_SERVER_HACK_ROOT+found}" != found ]]; then
	export VSCODE_SERVER_HACK_ROOT=/data/AppData/VSCodeRemote
	echo "VSCode Server files save to: $VSCODE_SERVER_HACK_ROOT" >&2
fi

declare -x TMPDIR="/tmp/vscode-server"

if [[ "$PROXY" ]]; then
	export http_proxy="$PROXY" https_proxy="$PROXY"
	echo "Using proxy: $PROXY" >&2
fi

export PATH="$LCODE_LIBEXEC:$PATH"
