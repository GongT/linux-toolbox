#!/usr/bin/bash

set -Eeuo pipefail

PIDFILE=$1

echo -n "$$" > "$PIDFILE"

function d() {
	echo "[NS] $*" >&2
}
function x() {
	d " + $*"
	"$@"
}

d "Hello! In Namespace! PID=$$"

create_ensure() {
	local F="$1"
	if ! [[ -d "$F" ]]; then
		d "create $F"
		mkdir "$F"
		x chattr +i "$F"
	fi
}

create_ensure "$HOME/.vscode-server-insiders"
create_ensure "$HOME/.vscode-server"

cd "$HOME"
d "bind .vscode-server"
x mount --bind "$VSCODE_SERVER_HACK_ROOT" ".vscode-server"

d "bind .vscode-server-insiders"
x mount --bind "$VSCODE_SERVER_HACK_ROOT" ".vscode-server-insiders"

d "go sleep"
sleep 30
d "mother process quit"

x rm -f "$PIDFILE"

sleep 10
