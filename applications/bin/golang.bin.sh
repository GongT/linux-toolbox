#!/bin/bash

# if ! [ -t 1 ] || ! [ -t 0 ]; then
# 	exec "$GOLANG" "$@"
# fi

if ! [[ "$TMPDIR" ]]; then
	TMPDIR="/tmp"
fi

export TMPDIR="$TMPDIR/golang"
if ! [[ -d "$TMPDIR" ]]; then
	mkdir -p "$TMPDIR"
fi

exec "${GOLANG}" "$@"
