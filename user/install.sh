#!/usr/bin/env bash

write_sshd_config() {
	local NAME=$1 LINE=$2
	if $SUDO test -d /etc/ssh/ssh_config.d; then
		local F="/etc/ssh/sshd_config.d/${NAME}.conf"
		echo "$LINE" | $SUDO tee --append "$F" >/dev/null
		echo "writting SSHD config file $F" >&2
	else
		local F="/etc/ssh/sshd_config"
		sudo env "PATH=$PATH" file-section /etc/ssh/sshd_config "LINUX_TOOLBOX - sshd - $NAME" "$LINE"
		echo "writting SSHD config file $F" >&2
	fi
}

emit_file vscode.sh
emit_file sshd.sh

source sshd.sh
VALUES="DISPLAY SSH_CLIENT_IP REMOTE_PATH SSH_ORIGIN_MACHINE VSCODE_CWD USERNAME"
write_sshd_config allow-input "AcceptEnv $VALUES"
file-section "$HOME/.ssh/ssh_config" linux-toolbox-allow-send "SendEnv $VALUES"
