if [[ "$USERNAME" ]]; then
	for i in $(seq 0 8); do
		echo "|" >&2
	done
	echo "Detected VSCode session; USERNAME=$USERNAME; SSH process PID is $$" >&2
	unset USERNAME

	if [[ "$PROXY" ]]; then
		export http_proxy="$PROXY" https_proxy="$PROXY"
		echo "Using proxy: $PROXY" >&2
	fi

	if mountpoint "$HOME/.vscode-server"; then
		echo "Already in namespace: $HOME/.vscode-server is mountpoint" >&2
		return
	fi

	if [[ "${VSCODE_SERVER_HACK_ROOT+found}" != found ]]; then
		declare -xr VSCODE_SERVER_HACK_ROOT=/data/AppData/VSCodeRemote
	fi
	echo "VSCode Server files save to: $VSCODE_SERVER_HACK_ROOT" >&2
	declare -xr VPATH="$(mktemp --dir)"
	declare -x TMPDIR="/tmp/vscode-server"
	declare -xr PID_FILE="/run/vscode-server.pid"
	export PATH="$VPATH:$PATH"

	{
		echo "ENV PATH:"
		echo -n '  | '
		echo "$PATH" | sed 's/:/\n  | /g'
	} >&2

	mkdir -p "$VPATH"
	cat > "$VPATH/ps" <<- 'BIN'
		#!/usr/bin/env bash
		if echo " $* " | grep -Eiq ' -?o' ; then
			exec /usr/bin/ps "$@"
		else
			declare -i SPID
			SPID=$(ls -Li /proc/1/ns/pid | awk '{print $1}')
			exec /usr/bin/ps -O pidns "$@" | grep " $SPID "
		fi
	BIN
	chmod a+x "$VPATH/ps"

	if ! systemctl is-active vscode-server-holder.service &> /dev/null; then
		echo "Start VSCode Server Holder Service." >&2
		mkdir -p "$VSCODE_SERVER_HACK_ROOT"
		systemd-run --slice=vscode.slice --collect --unit=vscode-server-holder.service \
			"--setenv=VSCODE_SERVER_HACK_ROOT=$VSCODE_SERVER_HACK_ROOT" \
			"--setenv=PATH=$PATH" \
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
		if systemctl is-active vscode-server-holder.service &> /dev/null; then
			echo "    - ok" >&2
		else
			echo "    - not able to start!" >&2
			systemctl status vscode-server-holder.service --no-pager
			exit 1
		fi
	else
		echo "VSCode Server Holder is running." >&2
	fi

	function e() {
		echo "[!!!] $*" >&2
		"$@"
	}
	function bash() {
		if ! [[ -f "$PID_FILE" ]]; then
			echo "unit vscode-server-holder.service can not start." >&2
			exit 1
		fi
		local PID="$(< "$PID_FILE")"
		if nsenter --mount --target "$PID" mountpoint "$HOME/.vscode-server" &> /dev/null; then
			e systemd-run --quiet --slice=vscode.slice --collect --scope --same-dir nsenter --no-fork "--wd=$(pwd)" --all --target "$PID" /usr/bin/bash "$@"
		else
			echo "something wrong in vscode-server-holder.service ($PID)"
			exit 1
		fi
	}
	echo "BASH replaced." >&2
fi
