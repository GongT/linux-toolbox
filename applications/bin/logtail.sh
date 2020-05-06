#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
	echo "Usage: $0 <... service names >" >&2
	exit 1
else
	ARGS=()
	for i in "$@"
	do
		ARGS+=(-u "$i")
	done
fi

journalctl -o cat -n 3 -f "${ARGS[@]}"
