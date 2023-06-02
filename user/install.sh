#!/usr/bin/env bash

write_sshd_config() {
	local NAME=$1 LINE=$2
	if "$SUDO" test -e /etc/ssh/ssh_config.d; then
		echo "$LINE" | $SUDO tee --append "/etc/ssh/sshd_config.d/$NAME" >/dev/null
	else
		sudo env "PATH=$PATH" file-section /etc/ssh/sshd_config "LINUX_TOOLBOX - sshd - $NAME" "$LINE"
	fi
}

sshd-allow-environment() {
	local title=$1
	shift
	local VALUES="$*"
	if [[ ! $VALUES ]]; then
		echo "Empty input!" >&2
		return 1
	fi

	write_sshd_config "$title" "AcceptEnv $VALUES"
}

emit_file vscode.sh
emit_file sshd.sh

source sshd.sh
VALUES="DISPLAY SSH_CLIENT_IP REMOTE_PATH SSH_ORIGIN_MACHINE VSCODE_CWD USERNAME"
sshd-allow-environment allow-input "$VALUES"
write_sshd_config allow-output "SendEnv $VALUES"
