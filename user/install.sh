#!/usr/bin/env bash

mkdir -p /etc/ssh/sshd_config.d
write_sshd_config() {
	local NAME=$1 LINE=$2
	local F="/etc/ssh/sshd_config.d/${NAME}.conf"
	echo "$LINE" | $SUDO tee "$F" >/dev/null
	echo "writting SSHD config file $F" >&2
}

write_ssh_config() {
	local NAME=$1 LINE=$2
	local F="/etc/ssh/ssh_config.d/${NAME}.conf"
	echo "$LINE" | $SUDO tee "$F" >/dev/null
	echo "writting SSH config file $F" >&2
}

emit_file vscode.sh
emit_file sshd.sh

source sshd.sh
VALUES=(
	DISPLAY
	SSH_CLIENT_IP
	REMOTE_PATH
	SSH_ORIGIN_MACHINE
	VSCODE_CWD
	USERNAME
	# VSCODE_IPC_HOOK_CLI
	TERM_PROGRAM
	TERM_PROGRAM_VERSION
	# VSCODE_SHELL_INTEGRATION_SHELL_SCRIPT
	COMPUTERNAME
	USER_DISPLAYNAME
	USER_EMAIL
)
write_sshd_config 89-linux-toolbox "AcceptEnv ${VALUES[*]}"
write_ssh_config 89-linux-toolbox "SendEnv ${VALUES[*]}"


# cat <<-EOF > /
# EOF
# socat -v UNIX-LISTEN:/tmp/x.sock,mode=0777 UNIX-CO
# NNECT:$VSCODE_IPC_HOOK_CLI
