#!/bin/bash

if command_exists podman; then
	debug "podman exists"
	PODMAN=$(find_command podman)
	copy_bin bin/podman_wrap.sh podman \
		"PODMAN=$PODMAN"
else
	debug "podman not found"
fi

cru d "podman-cleanup" "podman-auto-pull"

if command_exists buildah; then
	debug "buildah exists"
	BUILDAH=$(find_command buildah)
	copy_bin bin/buildah_wrap.sh buildah \
		"BUILDAH=$BUILDAH"
else
	debug "buildah not found"
fi
