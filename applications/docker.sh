#!/bin/bash

if command_exists docker; then
	DOCKER=$(find_command docker)
	warp_bin_with_env docker bin/docker_wrap.sh \
		"DOCKER=$DOCKER"
fi
