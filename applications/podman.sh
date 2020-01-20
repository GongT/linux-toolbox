#!/bin/bash

if ! command_exists podman ; then
	return 0
fi

PODMAN=$(command -v podman)
emit "alias podman=\"${VAR_HERE}/bin/podman_wrap '${PODMAN}'\""
emit "alias pps=\"${VAR_HERE}/bin/podman_wrap '${PODMAN}' pps\""
emit "alias pmg=\"${VAR_HERE}/bin/podman_wrap '${PODMAN}' pmg\""

