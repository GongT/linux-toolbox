if [[ "$USERNAME" ]] && ! [[ "${VSCODE_IPC_HOOK_CLI:-}" ]]; then
	for i in $(seq 0 8); do
		echo "|" >&2
	done

	echo "Detected VSCode session; USERNAME=$USERNAME; SSH process PID is $$" >&2
	echo "Bash Options: $- ; Arguments ($#): $*" >&2

	if [[ "$PROXY" ]]; then
		export http_proxy="$PROXY" https_proxy="$PROXY"
		echo "Using proxy: $PROXY" >&2
	fi

	export USERNAME=''
	unset USERNAME
fi
