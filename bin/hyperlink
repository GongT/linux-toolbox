#!/usr/bin/env bash

set -Eeuo pipefail

if [[ $# -lt 2 ]] || [[ $# -gt 3 ]]; then
	echo "Usage: $0 Title Url [Id]" >&2
	exit 1
fi

NAME=$1
URL=$2
ID=${3:-}
if [[ "$ID" ]]; then
	ID="id=$ID"
fi

printf '\e[4m\e]8;%s;%s\e\\%s\e]8;;\e\\\e[0m' "$ID" "$URL" "$NAME"
