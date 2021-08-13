if [[ "$USERNAME" ]] && [[ "$(id -u)" -eq 0 ]] && ! [[ "${VSCODE_IPC_HOOK_CLI:-}" ]]; then
	for i in $(seq 0 8); do
		echo "|" >&2
	done
	export USERNAME=''
	unset USERNAME
	echo "Detected VSCode session; USERNAME=$USERNAME; SSH process PID is $$" >&2
	echo "Bash Options: $- ; Arguments ($#): $*" >&2

	declare -rx LCODE_LIBEXEC="/usr/local/libexec/linux-toolbox/vscode-wrap"
	if [[ ${VSCODE_SERVER_HACK_ROOT+found} != found ]]; then
		export VSCODE_SERVER_HACK_ROOT=/data/AppData/VSCodeRemote
	fi
	echo "VSCode Server files save to: $VSCODE_SERVER_HACK_ROOT" >&2

	declare -x TMPDIR="/tmp/vscode-server"
	mkdir -p "$TMPDIR"

	if [[ "$PROXY" ]]; then
		export http_proxy="$PROXY" https_proxy="$PROXY"
		echo "Using proxy: $PROXY" >&2
	fi

	if mountpoint -q "$HOME/.vscode-server"; then
		echo "Already in namespace: $HOME/.vscode-server is mountpoint" >&2
		return
	fi

	mapfile -t PORTS < <(
		find "$VSCODE_SERVER_HACK_ROOT" -maxdepth 1 -name ".*.log" \
			| xargs cat | grep -oE 'listening on [[:digit:]]+' \
			| grep -oE '[[:digit:]]+'
	)

	replace_bash() {
		export TARGET_PID="$1"
		export PATH="$LCODE_LIBEXEC:$PATH"
		bash() {
			echo "[CALL] bash $*" >&2
			set -x
			tee "$TMPDIR/download-install-script.sh" | \
				nsenter --target "$TARGET_PID" --mount /usr/bin/bash "$@"
		}
		echo "BASH replaced. [target pid $TARGET_PID]" >&2
	}

	for P in "${PORTS[@]}"; do
		PID=$(lsof -n -i ":$P" | grep LISTEN | awk '{print $2}')
		if [[ "$PID" ]]; then
			echo "Found vscode remote server process: $PID" >&2
			replace_bash "$PID"
			return
		fi
	done

	echo "Did not found any running server..." >&2
	declare -r PIDFILE="/run/vscode-server-prepare-result.pid"

	if [[ -e $PIDFILE ]]; then
		echo "Pid file $PIDFILE exists." >&2
		if nsenter --target "$(<"$PIDFILE")" --all mountpoint "$HOME/.vscode-server" &>/dev/null; then
			echo "    And valid" >&2
			replace_bash "$(<"$PIDFILE")"
			return
		else
			echo "    But invalid" >&2
		fi
	fi

	{
		echo "ENV PATH:"
		echo -n '  | '
		echo "$PATH" | sed 's/:/\n  | /g'
	} >&2

	rm -f "$PIDFILE"
	unshare --mount --propagation slave bash "$LCODE_LIBEXEC/_vscode-server-prepare.sh" "$PIDFILE" &
	sleep 5

	replace_bash "$(<"$PIDFILE")"
	return
fi
