#!/bin/bash

MACHINECTL=$1
shift

if ! [ -t 1 ] || ! [ -t 0 ]; then
	exec "$@"
fi

function reload_network() {
	"${MACHINECTL}" list |
		grep ' container ' |
		awk '{print $1}' |
		xargs -IF \
			"${MACHINECTL}" \
			shell \
			F \
			/usr/bin/systemctl \
			restart \
			systemd-networkd
}

case $1 in
reload-network)
	shift
	reload_network
	;;
*)
	"${MACHINECTL}" "$@"
	;;
esac
