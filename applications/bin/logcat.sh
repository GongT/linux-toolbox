#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
	echo "Usage: $0 <... service names >" >&2
	exit 1
fi

ARGS=()
for i in "$@"
do
	ARGS+=(-u "$i")
done

journalctl -o cat -n 9000 "${ARGS[@]}"
