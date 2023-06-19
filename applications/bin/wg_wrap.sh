#!/usr/bin/env bash

set -Eeuo pipefail

declare -A IP_TO_NAME=()
if ! [[ -t 1 ]]; then
	exec "$@"
fi

function resolve_ip() {
	local NAME IP=$1
	NAME=$(host -W1 "$1" | awk '/domain name pointer/ { print $5 }')

	if [[ $NAME ]]; then
		IP_TO_NAME[$IP]=$NAME
		return 0
	else
		return 1
	fi
}

function show_color() {
	export WG_COLOR_MODE=always

	mapfile -t LINES < <(grep -vE '^\s*#' /etc/hosts | sed -E 's/\s+/ /g' | cut -d' ' -f1-2)
	for LINE in "${LINES[@]}"; do
		NAME=${LINE##* }
		IP=${LINE%% *}
		if [[ $NAME ]] && [[ "$IP" ]]; then
			IP_TO_NAME[$IP]=$NAME
		fi
	done

	OUTPUT=$("$@" | grep -v --fixed-strings '(hidden)')
	echo "$OUTPUT" | while IFS=$'\n' read -r LINE; do
		if [[ $LINE == *"allowed ips"* ]]; then
			echo -n "$LINE"
			IP=$(echo "$LINE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
			if [[ ${IP_TO_NAME[$IP]-} ]]; then
				echo -e "  (\e[38;5;10m${IP_TO_NAME[$IP]}\e[0m)"
			elif resolve_ip "$IP"; then
				echo -e "  (\e[38;5;10m${IP_TO_NAME[$IP]}\e[0m)"
			else
				echo -e "  (\e[38;5;9munknown\e[0m)"
			fi
		elif [[ $LINE == *"interface"* ]]; then
			IFNAME=$(echo "$LINE" | awk '{print $2}' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
			IP=$(ip address show dev "$IFNAME" | grep inet | head -n1 | awk '{print $2}')
			echo "$LINE"
			echo -e "  \e[1maddress\e[0m: $IP"
		elif [[ $LINE == *"persistent keepalive"* ]]; then
			:
		elif [[ $LINE == *"latest handshake"* ]]; then
			TIME_PART=$(echo "$LINE" | sed -E 's/\s+/ /g; s/^ | ago$|,//g' | cut -d ' ' -f 3- | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
			US=$({ systemd-analyze timespan "$TIME_PART" 2>/dev/null | grep 'μs' | awk '{print $2}'; } || echo 0)
			S=$((US / 1000000))
			if [[ $S -gt 130 ]]; then
				echo -e "$LINE \e[38;5;11m⚠ \e[0m"
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
