#!/bin/bash

if ! [ -t 1 ] || ! [ -t 0 ] ; then
	exec "$@"
fi

PODMAN=$1
shift

function clean_images {
	echo -e "\e[38;5;5mremoving images:\e[0m"
	podman images | grep -E '<none>'  | awk '{print $3}' | xargs --no-run-if-empty --verbose --no-run-if-empty podman rmi
}
function clear_stopped_container {
	echo -e "\e[38;5;5mremoving containers:\e[0m"
	podman ps -a | tail -n +2 | grep -v Up | awk '{print $1}' | xargs --no-run-if-empty --verbose --no-run-if-empty podman rm
}

function pps() {
	local FMT="$1"
	shift
	local OUT=$("${PODMAN}" ps --format "$FMT" -a "$@")
	local HEAD=$(echo "${OUT}" | head -1)
	if [[ -z "$HEAD" ]] ; then
		echo "no container exists."
		return
	fi
	OUT=$(echo "${OUT}" | tail -n +2 )
	local RUNNING=$(echo "${OUT}" | grep --color=no ' Up [0-9LA]')
	local EXITED=$(echo "${OUT}" | grep --color=no -v ' Up [0-9LA]')
	if [[ -n "$RUNNING" ]] ; then
		echo -e "\e[38;5;10mrunning pods:\e[0m"
		echo "$RUNNING"
	fi
	if [[ -n "$RUNNING" ]] && [[ -n "$EXITED" ]]; then
		echo '------'
	fi
	if [[ -n "$EXITED" ]] ; then
		echo -e "\e[38;5;9mstopped pods:\e[0m"
		echo "$EXITED"
	fi
}

case $1 in
ps)
	shift
	pps 'table {{.Names}} {{.ID}} {{.Status}}' "$@"
;;
pss)
	shift
	pps 'table {{.Names}} {{.ID}} {{.Image}} {{.Status}}' "$@"
;;
psss)
	shift
	"${PODMAN}" ps "$@"
;;
img)
	shift
	"${PODMAN}" images --format "table {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}" "$@"
;;
clean)
	shift
	clear_stopped_container
	clean_images
;;
*)
	"${PODMAN}" "$@"
esac