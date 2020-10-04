#!/usr/bin/env bash

set -Eeuo pipefail

function x() {
	echo -e "\e[2m + $*\e[0m" >&2
	"$@"
}

for pid in $(lsns -t mnt -n -o pid); do
	if x nsenter -t "$pid" umount -q --recursive "$@"; then
		echo "Yes"
	fi
done
