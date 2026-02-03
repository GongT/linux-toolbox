#!/bin/bash

if command_exists docker; then
	DOCKER=$(find_command docker)
	copy_bin bin/docker_wrap.sh docker \
		"DOCKER=$DOCKER"
fi
