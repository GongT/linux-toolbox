#!/usr/bin/env bash

set -Eeuo pipefail

if ! [ -t 1 ] || ! [ -t 0 ]; then
	exec "$PODMAN" "$@"
fi

BACKUP_PATH="${SYSTEM_COMMON_BACKUP:-/data/Backup}/containers"

function clean_images() {
	echo -e "\e[38;5;5mremoving images:\e[0m"
	"${PODMAN}" images | (grep -E '<none>' || [[ $? == 1 ]]) | awk '{print $3}' | xargs --no-run-if-empty --verbose --no-run-if-empty "${PODMAN}" rmi
}
function clear_stopped_container() {
	echo -e "\e[38;5;5mremoving containers:\e[0m"
	"${PODMAN}" ps -a | tail -n +2 | (grep -v Up || [[ $? == 1 ]]) | awk '{print $1}' | xargs --no-run-if-empty --verbose --no-run-if-empty "${PODMAN}" rm
}

function get_backup_label() {
	local FILE=$1
	local LABEL=${FILE#$BACKUP_PATH}
	LABEL=$(dirname "$LABEL")
	LABEL=${LABEL#/}
	echo "$LABEL/$(basename "$FILE" .tar.gz)"
}
function get_label_name() {
	local LBL=$1
	echo "${X%:*}"
}
function get_label_tag() {
	local LBL=$1
	echo "${X#*:}"
}

function do_backup() {
	local ACTION=${1:-}

	if [[ "$ACTION" == 'create' ]]; then
		local IMGS=() I OUT

		mapfile -t IMGS < <("${PODMAN}" images | tail -n +2 | grep -v '<none>' | awk '{print $1":"$2}')

		echo "backup directory: $BACKUP_PATH"
		for I in "${IMGS[@]}"; do
			echo "Backup image: $I"
			OUT="$BACKUP_PATH/${I}.tar.gz"
			mkdir -p "$(dirname "$OUT")"
			podman save "$I" | pv > "$OUT" || {
				echo "failed."
				return 1
			}
		done
	elif [[ "$ACTION" == 'restore' ]]; then
		mkdir -p "$BACKUP_PATH"

		local FILES I TMPDIR="$TMPDIR/podman" LBL
		mkdir -p "$TMPDIR"
		cd "$TMPDIR"

		echo "backup directory: $BACKUP_PATH"
		mapfile -t FILES < <(find "$BACKUP_PATH" -type f)

		for I in "${FILES[@]}"; do
			LBL=$(get_backup_label "$I")
			pv "$I" | podman load --quiet "$LBL"
		done
	else
		echo "Usage: podman backup <create|restore>${ACTION+$'\n'"  Invalid action: $ACTION"}"
		exit 1
	fi
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
backup)
	shift
	do_backup "$@"
	;;
*)
	"${PODMAN}" "$@"
	;;
esac
