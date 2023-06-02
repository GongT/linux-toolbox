#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
	echo "$(basename "$0") FILE
" >&2
}

if [[ $# -ne 1 ]]; then
	usage
	exit 1
fi

declare -r FILE=$1

if ! [[ -e $FILE ]]; then
	exit 0
fi

function file_ends_with_newline() {
	# https://stackoverflow.com/questions/38746/how-to-detect-file-ends-in-newline
	[[ $(tail -c1 "$1" | wc -l) -gt 0 ]]
}

if [[ -f $FILE ]]; then
	if ! file_ends_with_newline "$FILE" && [[ "$(<"$FILE")" ]]; then
		echo >>"$FILE"
	fi
else
	echo "$FILE is not a file" >&2
	exit 1
fi
