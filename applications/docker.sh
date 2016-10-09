#!/bin/bash

if ! command_exists docker ; then
	return 0
fi

copy_bin bin/dps

DOCKER=`which docker`
emit "alias docker=\"docker_wrap '${DOCKER}'\""
copy_bin bin/docker_wrap
