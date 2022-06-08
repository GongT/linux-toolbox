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

	O_BASH=$(env sh --noprofile --norc -c "command -v bash")
	O_PATH="$PATH"

	mkdir -p /tmp/vscode-server
	cp /usr/local/libexec/linux-toolbox/vscode-wrap/wget /tmp/vscode-server
	chmod a+x /tmp/vscode-server/wget
	export PATH="/tmp/vscode-server:$PATH"

	function bash() {
		local TMPF="/tmp/vscode-server/install-script.sh"
		if ! [[ -t 0 ]]; then
			cat >"$TMPF"
			echo -e "\e[2m + $O_BASH $* < ${TMPF}\e[0m"
			"$O_BASH" "$@" <"$TMPF"
		else
			echo -e "\e[2m + $O_BASH $*\e[0m"
			"$O_BASH" "$@"
		fi
		export PATH="$O_PATH"
		unset O_BASH O_PATH bash
	}
fi
