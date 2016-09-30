#!/bin/bash

if [ -z "${MY_SCRIPT_ROOT}" ]; then
	echo "linux-toolbox seems not installed correctly"
	exit 1
fi

COMMAND=${1}
shift
ARGS=$@

