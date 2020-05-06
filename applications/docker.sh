#!/bin/bash

if command_exists docker; then
	DOCKER=$(find_command docker)
	emit "alias docker=\"${VAR_HERE}/bin/docker_wrap '${DOCKER}'\""
fi
