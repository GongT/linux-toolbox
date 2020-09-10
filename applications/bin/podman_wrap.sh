#!/bin/bash

if ! [ -t 1 ] || ! [ -t 0 ]; then
	exec "$@"
fi

PODMAN=$1
shift

function clean_images() {
	echo -e "\e[38;5;5mremoving images:\e[0m"
	"${PODMAN}" images | grep -E '<none>' | awk '{print $3}' | xargs --no-run-if-empty --verbose --no-run-if-empty "${PODMAN}" rmi
}
function clear_stopped_container() {
	echo -e "\e[38;5;5mremoving containers:\e[0m"
	"${PODMAN}" ps -a | tail -n +2 | grep -v Up | awk '{print $1}' | xargs --no-run-if-empty --verbose --no-run-if-empty "${PODMAN}" rm
}

function pps() {
	local FMT="$1"
	shift
	local OUT=$("${PODMAN}" ps --format "$FMT" -a "$@")
	local HEAD=$(echo "${OUT}" | head -1)
	if [[ -z "$HEAD" ]]; then
		echo "no container exists."
		return
	fi
	local RUNNING=$(echo "${OUT}" | grep --color=no ' Up [0-9LA]')
	local EXITED=$(echo "${OUT}" | grep --color=no -v ' Up [0-9LA]')
	if [[ -n "$RUNNING" ]]; then
		echo -e "\e[38;5;10mrunning pods:\e[0m"
		echo "$RUNNING"
	fi
	if [[ -n "$RUNNING" ]] && [[ -n "$EXITED" ]]; then
		echo '------'
	fi
	if [[ -n "$EXITED" ]]; then
		echo -e "\e[38;5;9mstopped pods:\e[0m"
		echo "$EXITED"
	fi
}

case $1 in
ps)
	shift
	pps $'{{.Names}}\t{{.ID}}\t{{.Status}}' "$@" | sed 's/&gt;/>/g' | column -t -s $'\t'
	;;
pss)
	shift
	pps "table {{.Names}} {{.ID}} {{.Image}} {{.Status}}<nltab>Ports:{{.Ports}}<nltab>Mounts:{{.Mounts }}" "$@" \
		| sed -E 's/<nltab>/\n\t/g; s/^\s*(Ports|Mounts):\s*\n//mg; s/(Ports|Mounts):.+/\x1B[2m\0\x1B[0m/mg; s/^\S+/\x1B[38;5;14m\0\x1B[0m/mg'
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
xrmi)
	shift
	WHAT=$1
	if [[ "$WHAT" ]]; then
		"${PODMAN}" images "$@" --noheading | awk '{print $3}' | xargs -t --no-run-if-empty "${PODMAN}" rmi
	else
		echo "Usage: podman xrmi <part of image name>"
	fi
	;;
--help)
	if [[ $# -ne 1 ]]; then
		"${PODMAN}" "$@"
	else
		echo "This is a wrapper for 'podman'" >&2
		"${PODMAN}" --help
	fi
	;;
pull)
	shift
	if [[ $# -eq 1 ]] && [[ "$1" = "all" ]]; then
		"${PODMAN}" images | awk '{print $1":"$2}' | grep -- docker.io | xargs --no-run-if-empty -n1 -t "${PODMAN}" pull
	else
		"${PODMAN}" pull "$@"
	fi
	;;
*)
	"${PODMAN}" "$@"
	;;
esac
