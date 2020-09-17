#!/usr/bin/env bash

set -Eeuo pipefail

if ! [ -t 1 ] || ! [ -t 0 ]; then
	exec "$BUILDAH" "$@"
fi

_ls_img() {
	"${BUILDAH}" images --format "table {{.ID}}\t{{.Name}}:{{.Tag}}\t{{.Size}}" "$@"
}

_cache() {
	local ACTION="$1"
	case "$ACTION" in
	clear)
		_ls_img | grep --color=never ':stage-'
		;;
	list)
		_ls_img | grep --color=never ':stage-'
		;;
	*)
		echo "Usage: buildah cache [clean|list]" >&2
		exit 1
		;;
	esac
}

case $1 in
clean)
	"${BUILDAH}" containers -n --format '{{.ContainerID}}' | xargs --no-run-if-empty "${BUILDAH}" rm
	;;
cache)
	shift
	_cache "$@"
	;;
img)
	shift
	_ls_img "$@"
	;;
*)
	"${BUILDAH}" "$@"
	;;
esac
