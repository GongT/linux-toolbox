#!/bin/bash

if command_exists podman ; then
	PODMAN=$(find_command podman)
	emit "alias podman=\"${VAR_HERE}/bin/podman_wrap '${PODMAN}'\""
fi

if command_exists buildah ; then
	BUILDAH=$(find_command buildah)
	emit "alias buildah=\"${VAR_HERE}/bin/buildah_wrap '${BUILDAH}'\""
fi
