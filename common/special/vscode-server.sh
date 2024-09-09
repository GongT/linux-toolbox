if [[ "$USERNAME" ]] && ! [[ "${VSCODE_IPC_HOOK_CLI-}" ]]; then
	# for i in $(seq 0 8); do
	#	echo "" #>&2
	# done

	echo "Detected VSCode session; USERNAME=$USERNAME; LINUX_TOOLBOX_INITED=$LINUX_TOOLBOX_INITED; SSH process PID is $$" >&2
	echo "Bash Options: $- ; Arguments ($#): $* ; SHELL=$SHELL" >&2
	# /usr/bin/pstree --ascii --long --show-pids --show-parents --arguments $$ >&2

	if [[ "$PROXY" ]]; then
		export http_proxy="$PROXY" https_proxy="$PROXY"
		echo "Using proxy: $PROXY" >&2
	else
		echo "Not using proxy" >&2
	fi
	if ! [[ "$VSCODE_AGENT_FOLDER" ]]; then
		VSCODE_AGENT_FOLDER="$HOME/.vscode-server"
	fi
	echo "force vscode install to $VSCODE_AGENT_FOLDER" >&2

	export USERNAME=''
	unset USERNAME

	O_BASH=$SHELL # $(env sh --noprofile --norc -c "command -v bash")

	mkdir -p /tmp/vscode-server
	cp "$MY_LIBEXEC/vscode-wrap/wget" /tmp/vscode-server
	chmod a+x /tmp/vscode-server/wget

	function sh() {
		bash "$@"
	}
	function bash() {
		local TMPF="/tmp/vscode-server/install-script.sh"
		if ! [[ -t 0 ]]; then
			echo -e "\e[2m + $O_BASH $* < ${TMPF}\e[0m" >&2
			sed --unbuffered "s|^VSCODE_AGENT_FOLDER=.*$|export VSCODE_AGENT_FOLDER='$VSCODE_AGENT_FOLDER'|g" | tee "$TMPF" | PATH="/tmp/vscode-server:$PATH" "$O_BASH" "$@"
		else
			echo -e "\e[2m + $O_BASH $*\e[0m" >&2
			"$O_BASH" "$@"
		fi
	}
fi
