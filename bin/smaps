#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

if [[ $EUID -ne 0 ]]; then
	exec sudo "$0" "$@"
fi

print_one_pid() {
	local pid=$1
	local cmdline smaps_rollup TARGET_FILE

	if [[ -e "/proc/${pid}/cmdline" ]]; then
		mapfile -d '' -t cmdline <"/proc/${pid}/cmdline"
		cmdline[0]=$(basename "${cmdline[0]}")
	else
		cmdline=("<unknown>")
	fi

	printf "\e[48;5;14m %s \e[0;2m %s\e[0m\n" "$pid" "${cmdline[*]}"

	TARGET_FILE="/proc/${pid}/smaps_rollup"
	if [[ ! -e $TARGET_FILE ]]; then
		echo "  无法访问 ${TARGET_FILE}，可能是进程已终止。"
		return
	fi

	smaps_rollup=$(<"$TARGET_FILE")

	# all is in kb in smaps_rollup, convert to bytes
	local pss pc pd sc sd sw
	while IFS= read -r line; do
		case "$line" in
		Pss:*) pss=$(echo "$line" | awk '{print $2 * 1024}') ;;
		Private_Clean:*) pc=$(echo "$line" | awk '{print $2 * 1024}') ;;
		Private_Dirty:*) pd=$(echo "$line" | awk '{print $2 * 1024}') ;;
		Shared_Clean:*) sc=$(echo "$line" | awk '{print $2 * 1024}') ;;
		Shared_Dirty:*) sd=$(echo "$line" | awk '{print $2 * 1024}') ;;
		Swap:*) sw=$(echo "$line" | awk '{print $2 * 1024}') ;;
		esac
	done <<<"$smaps_rollup"

	printf "  总占用: %s\n  私有: %s\n  共享: %s\n  已交换: %s\n" \
		"$(numfmt --to=iec --suffix=B "$pss")" \
		"$(numfmt --to=iec --suffix=B "$((pc + pd))")" \
		"$(numfmt --to=iec --suffix=B "$((sc + sd))")" \
		"$(numfmt --to=iec --suffix=B "$sw")"
}

if [[ $# -eq 0 ]]; then
	echo "Usage: $0 [PID...]"
	echo "  Example: $0 \$(pgrep -f my_process)"
	exit 1
fi

for pid in "$@"; do
	print_one_pid "$pid"
	echo
done
