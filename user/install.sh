#!/bin/sh

emit_file vscode.sh
emit_file sshd.sh

source sshd.sh
sshd-allow-environment linux-toolbox-inserted DISPLAY SSH_CLIENT_IP REMOTE_PATH SSH_ORIGIN_MACHINE
