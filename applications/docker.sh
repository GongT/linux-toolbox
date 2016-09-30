#!/bin/bash

if ! command_exists bower ; then
	return 0
fi


function dps {
	OUT=$(docker ps --format 'table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Status}}' -a $@)
	echo "${OUT}" | head -1
	OUT=$(echo "${OUT}" | tail -n +2 )
	echo "${OUT}" | grep --color=no ' Up [0-9LA]'
	echo '------'
	echo "${OUT}" | grep --color=no -v ' Up [0-9LA]'
}
