#!/usr/bin/bash

set -Eeuo pipefail

PIDFILE=$1

echo -n "$$" > "$PIDFILE"

function d() {
	echo "$*" >&2
}

d "[NS] Hello! In Namespace! PID=$$"

create_ensure() {
	local F="$1"
	if ! [[ -e "$F" ]]; then
		d "[NS] create $F"
		mkdir "$F"
		chattr +i "$F"
	fi
}

create_ensure "$HOME/.vscode-server-insiders"
create_ensure "$HOME/.vscode-server"

cd "$HOME"
d "[NS] bind .vscode-server"
mount --bind "$VSCODE_SERVER_HACK_ROOT" ".vscode-server"

d "[NS] bind .vscode-server-insiders"
mount --bind "$VSCODE_SERVER_HACK_ROOT" ".vscode-server-insiders"

d "[NS] go sleep"
sleep 30
d "[NS] mother process quit"

rm -f "$PIDFILE"

sleep 10

