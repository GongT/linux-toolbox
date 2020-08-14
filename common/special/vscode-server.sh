while [[ "$USERNAME" ]]; do
	set -x
	echo "Detected VSCode session; USERNAME=$USERNAME; SSH process PID is $$" >&2
	unset USERNAME

	if [[ "$PROXY" ]]; then
		export http_proxy="$PROXY" https_proxy="$PROXY"
		echo "Using proxy: $PROXY" >&2
	fi

	if mountpoint "$HOME/.vscode-server" ; then
		break
	fi

	declare -xr VSCODE_SERVER_HACK_ROOT=/data/AppData/VSCodeRemote
	declare -xr PID_FILE=/run/vscode-server.pid
	export TMPDIR="/tmp/vscode-server"
	mkdir -p "$VSCODE_SERVER_HACK_ROOT"

	if ! systemctl is-active vscode-server-holder.service ; then
		mkdir -p "$HOME/.vscode-server-insiders" "$HOME/.vscode-server"
		systemd-run --collect --unit=vscode-server-holder.service \
			"--setenv=VSCODE_SERVER_HACK_ROOT=$VSCODE_SERVER_HACK_ROOT" \
			"--setenv=HOME=$HOME" \
			"--setenv=PID_FILE=$PID_FILE" \
			"--setenv=TMPDIR=$TMPDIR" \
			"--property=CPUWeight=70" \
			"--property=PIDFile=$PID_FILE" \
			"--property=NotifyAccess=all" \
			--service-type=notify \
			unshare --cgroup --mount --kill-child=SIGTERM /usr/bin/bash -x "/usr/local/libexec/vscode-server-prepare.sh"
		sleep 2
		rmdir "$HOME/.vscode-server-insiders" "$HOME/.vscode-server" &>/dev/null
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
			echo "something wrong in _vscode-server-prepare, see log of vscode-server-holder.service"
			exit 1
		fi
	}
	set +x
	echo "BASH replaced." >&2
done
