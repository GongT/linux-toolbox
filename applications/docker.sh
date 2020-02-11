#!/bin/bash

if ! command_exists docker ; then
	return 0
fi

copy_bin bin/dps
copy_bin bin/dmg
copy_bin bin/mongo-shell

DOCKER=$(find_command docker)
emit "alias docker=\"${VAR_HERE}/bin/docker_wrap '${DOCKER}'\""
copy_bin bin/docker_wrap
