#!/bin/bash

if command_exists podman; then
	echo "podman exists"
	PODMAN=$(find_command podman)
	copy_bin_with_env \
		"PODMAN='$PODMAN'" \
		"bin/podman_wrap.sh" \
		"podman"
else
	echo "podman not found"
fi

cru d "podman-cleanup" "podman-auto-pull"

if command_exists buildah; then
	echo "podman buildah"
	BUILDAH=$(find_command buildah)
	copy_bin_with_env \
		"BUILDAH='$BUILDAH'" \
		"bin/buildah_wrap.sh" \
		"buildah"
else
	echo "podman not found"
fi
