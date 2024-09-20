#!/usr/bin/env bash

if [[ $# -eq 0 ]]; then
	echo "Usage: $0 <... service names >" >&2
	exit 1
fi

ARGS=()
for i in "$@"; do
	ARGS+=(-u "$i")
done

if [[ $UID -ne 0 ]]; then
	if [[ ${#ARGS[@]} -gt 0 ]]; then
		if systemctl --user cat "${ARGS[1]}" &>/dev/null; then
			ARGS+=(--user)
		else
			ARGS+=(--system)
		fi
	else
		ARGS+=(--user)
	fi
fi

x() {
	printf "\e[2m + %s\e[0m\n" "$*" >&2
	"$@"
}

x journalctl -o cat -n 3 -f "${ARGS[@]}"
