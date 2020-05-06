#!/bin/sh

emit_file vscode.sh
emit_file sshd.sh

source sshd.sh
VALUES="DISPLAY SSH_CLIENT_IP REMOTE_PATH SSH_ORIGIN_MACHINE"
sshd-allow-environment linux-toolbox-inserted "$VALUES"

mkdir -p /etc/ssh/ssh_config.d
echo "SendEnv $VALUES" >/etc/ssh/ssh_config.d/80-linux-toolbox.conf
