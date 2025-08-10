#!/bin/bash

if command_exists podman; then
	echo "podman exists"
	PODMAN=$(find_command podman)
	warp_bin_with_env podman bin/podman_wrap.sh \
		"PODMAN=$PODMAN"
else
	echo "podman not found"
fi

cru d "podman-cleanup" "podman-auto-pull"

if command_exists buildah; then
	echo "buildah exists"
	BUILDAH=$(find_command buildah)
	warp_bin_with_env buildah bin/buildah_wrap.sh \
		"BUILDAH=$BUILDAH"
else
	echo "buildah not found"
fi
