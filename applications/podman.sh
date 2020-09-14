#!/bin/bash

if command_exists podman; then
	PODMAN=$(find_command podman)
	emit "alias podman=\"${VAR_HERE}/bin/podman_wrap.sh '${PODMAN}'\""
	cru a "podman-cleanup" "*/5 * * * * /usr/bin/env bash '$HERE/bin/podman_wrap.sh' clean"
	cru a "podman-auto-pull" "0 */8 * * * /usr/bin/env bash '$HERE/staff/podman-pull-all.sh'"
else
	cru d "podman-cleanup"
	cru d "podman-auto-pull"
fi


if command_exists buildah; then
	BUILDAH=$(find_command buildah)
	emit "alias buildah=\"${VAR_HERE}/bin/buildah_wrap.sh '${BUILDAH}'\""
fi
