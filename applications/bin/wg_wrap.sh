#!/usr/bin/env bash

# shellcheck disable=SC2155,SC2034

set -Eeuo pipefail

declare -A IP_TO_NAME=()
if ! [[ -t 1 ]]; then
	exec "${WG}" "$@"
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

_COLOR_=
if [[ ${WG_COLOR_MODE-} == "always" ]]; then
	_COLOR_=1
elif [[ ${WG_COLOR_MODE-} == "never" ]]; then
	:
else
	if [[ -t 1 ]]; then
		_COLOR_=1
	fi
fi

if [[ $_COLOR_ ]]; then
	yellow() {
		if [[ $1 == -b ]]; then
			shift
			printf '\e[1;33m%s\e[0m' "$*"
		else
			printf '\e[33m%s\e[0m' "$*"
		fi
	}
	green() {
		if [[ $1 == -b ]]; then
			shift
			printf '\e[1;32m%s\e[0m' "$*"
		else
			printf '\e[32m%s\e[0m' "$*"
		fi
	}
	blue() {
		if [[ $1 == -b ]]; then
			shift
			printf '\e[1;34m%s\e[0m' "$*"
		else
			printf '\e[34m%s\e[0m' "$*"
		fi
	}
	red() {
		if [[ $1 == -b ]]; then
			shift
			printf '\e[1;31m%s\e[0m' "$*"
		else
			printf '\e[31m%s\e[0m' "$*"
		fi
	}
	bold() {
		if [[ $1 == -b ]]; then
			shift
			printf '\e[1m%s\e[0m' "$*"
		else
			printf '\e[1m%s\e[0m' "$*"
		fi
	}
else
	yellow() {
		if [[ $1 == -b ]]; then
			shift
		fi
		printf '%s' "$*"
	}
	green() {
		if [[ $1 == -b ]]; then
			shift
		fi
		printf '%s' "$*"
	}
	blue() {
		if [[ $1 == -b ]]; then
			shift
		fi
		printf '%s' "$*"
	}
	red() {
		if [[ $1 == -b ]]; then
			shift
		fi
		printf '%s' "$*"
	}
	bold() {
		printf '%s' "$*"
	}
fi
unset _COLOR_

function resolve_ip_to_host() {
	local IP=$1
	dig +short -x "$IP"
}

function print_peer() {
	local PEER="$1"
	local PUB_KEY=$(echo "$PEER" | cut -f1)
	local PSK=$(echo "$PEER" | cut -f2)
	local ENDPOINT=$(echo "$PEER" | cut -f3)
	local ALLOWED_IPS=$(echo "$PEER" | cut -f4)
	local LAST_HANDSHAKE=$(echo "$PEER" | cut -f5)
	local TRANSFER_RX=$(echo "$PEER" | cut -f6)
	local TRANSFER_TX=$(echo "$PEER" | cut -f7)
	local PERSISTENT_KEEPALIVE=$(echo "$PEER" | cut -f8)

	local IP RESOLVED_HOSTNAME="$(red no address)" RESOLVED=no IP_LIST=""
	for IP in $(echo "$ALLOWED_IPS" | tr ',' '\n'); do
		if [[ -n $IP_LIST ]]; then
			IP_LIST+=", "
		fi
		if is_single "${IP}"; then
			IP=${IP%%/*}
			if [[ ${RESOLVED} != yes ]]; then
				local RESULT=$(resolve_ip_to_host "$IP")
				if [[ $RESULT ]]; then
					RESOLVED_HOSTNAME=$(green "$RESULT")
					RESOLVED=yes
				else
					RESOLVED_HOSTNAME=$(red "unresolved")
				fi
			fi
			IP_LIST+="$IP"
		else
			local ADDR=$(ipcalc "$IP" --address --no-decorate) PREFIX=$(ipcalc "$IP" --prefix --no-decorate)
			IP_LIST+=$(printf "%s%s%s" "$ADDR" "$(blue '/')" "$PREFIX")
		fi
	done

	printf "%s: %s %s\n" "$(yellow -b peer)" "$(yellow "$PUB_KEY")" "${RESOLVED_HOSTNAME}"
	if [[ $PSK != '(none)' ]]; then
		printf "  %s: %s\n" "$(bold "preshared key")" "${PSK}"
	fi
	if [[ "${ENDPOINT}" ]]; then
		printf "  %s: %s\n" "$(bold "endpoint")" "${ENDPOINT}"
	fi
	if [[ "${ALLOWED_IPS}" ]]; then
		printf "  %s: %s\n" "$(bold "allowed ips")" "${IP_LIST}"
	fi
	if [[ ${LAST_HANDSHAKE} != '0' ]]; then
		printf "  %s: %s\n" "$(bold "last handshake")" "$(date -d "@${LAST_HANDSHAKE}" --iso-8601=seconds)"
	fi
	if [[ ${TRANSFER_RX} != '0' ]]; then
		printf "  %s: %s received, %s sent\n" "$(bold "transfer")" \
			"$(numfmt --to=iec-i --suffix=B --format "%0.2f" "${TRANSFER_RX}")" \
			"$(numfmt --to=iec-i --suffix=B --format "%0.2f" "${TRANSFER_TX}")"
	fi
}

function show_interface() {
	local INTERFACE=$1 MAIN=$2 PEERS=("${@:3}")

	local JSON=$(ip --json address show dev "$INTERFACE" | jq -r '.[0]')

	local IF_INDEX=$(echo "$JSON" | jq -r '.ifindex')
	local IF_MTU=$(echo "$JSON" | jq -r '.mtu')

	local PRI_KEY=$(echo "$MAIN" | cut -f1)
	local PUB_KEY=$(echo "$MAIN" | cut -f2)
	local LISTEN_PORT=$(echo "$MAIN" | cut -f3)
	# local FWMARK=$(echo "$MAIN" | cut -f4)

	printf "%s: %s (%d)\n" "$(green -b interface)" "$(green "$INTERFACE")" "${IF_INDEX}"
	printf "  %s: %s\n" "$(bold public key)" "$PUB_KEY"
	printf "  %s: %s\n" "$(bold private key)" "$PRI_KEY"
	printf "  %s: %s\n" "$(bold listening port)" "$LISTEN_PORT"
	printf "  %s: %s\n" "$(bold mtu)" "${IF_MTU}"

	local ADDR_COUNT=$(echo "$JSON" | jq -r '.addr_info | length')
	for i in $(seq 0 "$((ADDR_COUNT - 1))"); do
		local ADDR=$(echo "$JSON" | jq -r ".addr_info[$i].local")
		local PREFIX=$(echo "$JSON" | jq -r ".addr_info[$i].prefixlen")

		printf "  %s: %s%s%s\n" "$(bold address)" "$ADDR" "$(blue "/")" "${PREFIX}"
	done

	for PEER in "${PEERS[@]}"; do
		printf "\n"
		print_peer "$PEER"
	done
}

function is_single() {
	local NET=$1
	local ADDR_NUM=$(ipcalc "$NET" --addresses --no-decorate)
	[[ $ADDR_NUM -eq 1 ]]
}

function show_color() {
	export WG_COLOR_MODE=always
	local MAIN="" PEERS=() CURRENT_IF="" LINES=() IS_FIRST=1

	mapfile -t LINES < <(wg show all dump)

	for LINE in "${LINES[@]}"; do
		IFACE=$(echo "$LINE" | awk '{ print $1 }')
		VALUE=$(echo "$LINE" | cut -f1 --complement)
		if [[ $IFACE != "${CURRENT_IF}" ]]; then
			if [[ $MAIN ]]; then
				if [[ $IS_FIRST -eq 0 ]]; then
					printf "\n"
				fi
				IS_FIRST=0

				show_interface "$CURRENT_IF" "$MAIN" "${PEERS[@]}"
			fi

			CURRENT_IF=$IFACE
			MAIN="${VALUE}"
			PEERS=()
		else
			PEERS+=("$VALUE")
		fi
	done

	if [[ $MAIN ]]; then
		if [[ $IS_FIRST -eq 0 ]]; then
			printf "\n"
		fi
		show_interface "$CURRENT_IF" "$MAIN" "${PEERS[@]}"
	fi
}

if [[ $# -eq 0 ]]; then
	show_color "$@"
else
	exec "${WG}" "$@"
fi
