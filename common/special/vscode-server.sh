if [[ "$USERNAME" ]]; then
	set -x
	echo "Detected VSCode session; USERNAME=$USERNAME; SSH process PID is $$" >&2
	unset USERNAME

	if [[ "$PROXY" ]]; then
		export http_proxy="$PROXY" https_proxy="$PROXY"
		echo "Using proxy: $PROXY" >&2
	fi

	if mountpoint "$HOME/.vscode-server" ; then
		return
	fi

	declare -xr VSCODE_SERVER_HACK_ROOT=/data/AppData/VSCodeRemote
	declare -xr TMPDIR="/tmp/vscode-server"
	declare -xr PID_FILE="/run/vscode-server.pid"

	if ! systemctl is-active vscode-server-holder.service ; then
		mkdir -p "$VSCODE_SERVER_HACK_ROOT"
		systemd-run --slice=vscode.slice --collect --unit=vscode-server-holder.service \
			"--setenv=VSCODE_SERVER_HACK_ROOT=$VSCODE_SERVER_HACK_ROOT" \
			"--setenv=PATH=/tmp/.vscode-bin-wrapper:$PATH" \
			"--setenv=HOME=$HOME" \
			"--setenv=TMPDIR=$TMPDIR" \
			"--property=PIDFile=$PID_FILE" \
			"--property=CPUWeight=70" \
			"--property=NotifyAccess=all" \
			"--property=PrivateDevices=yes" \
			"--property=KillMode=control-group" \
			"--property=PrivateMounts=yes" \
			"--property=TemporaryFileSystem=$TMPDIR" \
			"--property=BindPaths=$VSCODE_SERVER_HACK_ROOT:$HOME/.vscode-server" \
			"--property=BindPaths=$VSCODE_SERVER_HACK_ROOT:$HOME/.vscode-server-insiders" \
			"--service-type=simple" \
			/usr/bin/bash -c 'echo $$$$ > "$$PIDFILE"; while true; do sleep infinity ; done'
		sleep 2
		# rmdir "$HOME/.vscode-server-insiders" "$HOME/.vscode-server" &>/dev/null
	fi

	function bash() {
		set -x
		if ! [[ -f "$PID_FILE" ]]; then
			echo "unit vscode-server-holder.service can not start."
			exit 1
		fi
		local PID="$(< "$PID_FILE")"
		if nsenter --mount --target "$PID" mountpoint "$HOME/.vscode-server" &>/dev/null ; then
			exec nsenter --no-fork "--wd=$(pwd)" --all --target "$PID" /usr/bin/bash
		else
			echo "something wrong in vscode-server-holder.service"
			exit 1
		fi
	}
	set +x
	echo "BASH replaced." >&2
fi
