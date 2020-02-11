#!/bin/bash

if ! [ -t 1 ] || ! [ -t 0 ] ; then
	exec "$@"
fi

BUILDAH=$1
shift

case $1 in
clean)
	"${BUILDAH}" containers -n --format '{{.ContainerID}}' | xargs --no-run-if-empty "${BUILDAH}" rm
;;
*)
	"${BUILDAH}" "$@"
esac
