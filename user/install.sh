#!/usr/bin/env bash

mkdir -p /etc/ssh/sshd_config.d
write_sshd_config() {
	local NAME=$1 LINE=$2
	local F="/etc/ssh/sshd_config.d/${NAME}.conf"
	write_file_if_changed "$F" "$LINE"
	debug "write sshd server config - ${LAST_FILE_CHANGED}"
}

write_ssh_config() {
	local NAME=$1 LINE=$2
	local F="/etc/ssh/ssh_config.d/${NAME}.conf"
	write_file_if_changed "$F" "$LINE"
	debug "write system ssh client config - ${LAST_FILE_CHANGED}"
}

write_sudoers_config() {
	local NAME=$1
	local F="/etc/sudoers.d/${NAME}"
	local LINES=$'# pass env vars to sudo\n'

	LINES+="Defaults env_keep=\"${VALUES[*]}\""

	write_file_if_changed "$F" "$LINES"
	debug "update sudoers file - ${LAST_FILE_CHANGED}"
	sudo chmod 0440 "$F"

	if ! visudo -c >/dev/null; then
		unlink "$F"
		die "error in sudoers file!"
	fi
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
write_sudoers_config 89-linux-toolbox

# cat <<-EOF > /
# EOF
# socat -v UNIX-LISTEN:/tmp/x.sock,mode=0777 UNIX-CO
# NNECT:$VSCODE_IPC_HOOK_CLI
