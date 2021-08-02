#!/usr/bin/env bash

set -Eeuo pipefail

if ! [[ -t 1 ]]; then
	exec "$@"
fi

function show_color() {
	export WG_COLOR_MODE=always

	declare -A IP_TO_NAME=()
	mapfile -t LINES < <(grep -vE '^\s*#' /etc/hosts | sed -E 's/\s+/ /g' | cut -d' ' -f1-2)
	for LINE in "${LINES[@]}"; do
		NAME=${LINE##* }
		IP=${LINE%% *}
		if [[ $NAME ]] && [[ "$IP"  ]]; then
			IP_TO_NAME[$IP]=$NAME
		fi
	done

	OUTPUT=$("$@" | grep -v --fixed-strings '(hidden)')
	echo "$OUTPUT" | while IFS=$'\n' read -r LINE; do
		if [[ $LINE == *"allowed ips"* ]]; then
			echo -n "$LINE"
			IP=$(echo "$LINE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
			if [[ ${IP_TO_NAME[$IP]:-} ]]; then
				echo -e "  (\e[38;5;10m${IP_TO_NAME[$IP]}\e[0m)"
			else
				echo -e "  (\e[38;5;9munknown\e[0m)"
			fi
		elif [[ $LINE == *"persistent keepalive"* ]]; then
			:
		elif [[ $LINE == *"latest handshake"* ]]; then
			TIME_PART=$(echo "$LINE" | sed -E 's/\s+/ /g; s/^ | ago$|,//g' | cut -d ' ' -f 3- | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
			US=$({ systemd-analyze timespan "$TIME_PART" | grep 'μs' | awk '{print $2}'; } || echo 0)
			S=$((US / 1000000))
			if [[ $S -gt 130 ]]; then
				echo -e "$LINE \e[38;5;11m⚠\e[0m"
			else
				echo -e "$LINE"
			fi
		else
			echo "$LINE"
		fi
	done
}

if [[ $# -eq 1 ]]; then
	show_color "$@"
elif [[ $# -eq 2 ]] && [[ $2 == show ]]; then
	show_color "$@"
elif [[ $# -eq 3 ]] && [[ $2 == show ]] && [[ $3 != interfaces ]] && [[ $3 != --help ]]; then
	show_color "$@"
else
	exec "$@"
fi
