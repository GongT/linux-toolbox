#!/usr/bin/env bash

set -Eeuo pipefail

if [[ "${VSCODE_SERVER_HACK_ROOT+found}" != found ]]; then
echo "this script must call by service"
	exit 1
fi

mkdir -p "$HOME/.vscode-server-insiders" "$HOME/.vscode-server"

export PATH="/tmp/.vscode-bin-wrapper:$PATH"

echo $$ > "$PID_FILE"

mkdir -p "$HOME/.vscode-server-insiders" "$HOME/.vscode-server"
cd "$HOME"
mount --bind "$VSCODE_SERVER_HACK_ROOT" ".vscode-server"
mount --bind "$VSCODE_SERVER_HACK_ROOT" ".vscode-server-insiders"

mkdir -p "$TMPDIR"
mount -t tmpfs tmpfs "$TMPDIR"

systemd-notify --ready

while true ; do
	sleep 3600
done
