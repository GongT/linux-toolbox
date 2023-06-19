#!/usr/bin/env bash

set -Eeuo pipefail

declare -i _TABLE_COLS=0
declare -a _TABLE_DATA=()
declare -a _TABLE_WIDTH=()

function table_start() {
	_TABLE_COLS=$#
	_TABLE_DATA=()
	for I; do
		_TABLE_DATA+=("\e[1m$I\e[0m")
	done
	_TABLE_WIDTH=()
	for I; do
		I=$(echo "$I" | wc -L)
		I=$((I + 2))
		_TABLE_WIDTH+=("$I")
	done
}
function table_row() {
	local W I INDEX
	_TABLE_DATA+=("$@")
	for I in $(seq 1 $#); do
		INDEX=$((I - 1))
		W=$(echo -ne "${!I}" | sed 's/\x1b\[[0-9;]*m//g' | wc -L)
		W=$((W + 3))
		if [[ $W -gt ${_TABLE_WIDTH[$INDEX]} ]]; then
			_TABLE_WIDTH[$INDEX]="$W"
		fi
	done
}
function table_print() {
	while [[ ${#_TABLE_DATA[@]} -gt 0 ]]; do
		for I in $(seq 0 $((_TABLE_COLS - 1))); do
			DATA=${_TABLE_DATA[0]}
			_TABLE_DATA=("${_TABLE_DATA[@]:1}")

			MW=${_TABLE_WIDTH[$I]}
			W=$(echo -e "${DATA}" | sed 's/\x1b\[[0-9;]*m//g' | wc -L)

			echo -ne "$DATA"
			printf "%*s" $((MW - W)) ''
		done
		echo
	done
}

main() {
	local CMD=${1-}
	shift

	case "$CMD" in
	show)
		cmd_show "$@"
		;;
	devices)
		cmd_devices "$@"
		;;
	*)
		help >&2
		exit 1
		;;
	esac
}

cmd_show() {
	cd /sys/class/hwmon
	for PA in *; do
		pushd "$PA" &>/dev/null

		popd &>/dev/null
	done
}
cmd_devices() {
	cd /sys/class/hwmon

	table_start "#" "名称" "数值" "范围" ""
	mapfile -t PS < <(find . -maxdepth 1 -name "hwmon*")
	for PA in "${PS[@]}"; do
		PA=$(basename "$PA")
		NAME=$(<"$PA/name")
		PAT=$(realpath "$(readlink "$PA")")

		echo -e "\e[38;5;10m$PA\e[0m:"
		echo "    NAME: $NAME"
		echo "    PATH: $PAT"


		# TODO
	done
	table_print
}

help() {
	echo -e "\e[38;5;11mPWM and Temperature tool\e[0m"
	echo "    pwm <command> [...options]"
	echo "Commands:"
	echo "    show [...device names]: display all avaiable information"
	echo "    devices: list active hwmon devices"
}

main "$@"
