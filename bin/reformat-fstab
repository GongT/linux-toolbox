#!/usr/bin/env bash

set -Eeuo pipefail

FSTAB=${1:-/etc/fstab}
BACKUP=$(mktemp --dry-run)

echo "Reformatting fstab file $FSTAB, backup to: $BACKUP"
cp "$FSTAB" "$BACKUP"

declare -ia FIELD_SIZE_ARR=()
function updateSize() {
	local I
	for I in $(seq 1 $#); do
		local V="${!I}"
		local -i SIZE="${#V} + 1"
		if [[ ${FIELD_SIZE_ARR[$I]:-0} -lt $SIZE ]]; then
			# echo "UpdateSize: $I -> $SIZE ($V)"
			FIELD_SIZE_ARR[$I]=$SIZE
		fi
	done
}

function pad() {
	local V="$2"
	local -i SIZE="$1" VSIZE="${#V}"
	local -i NEED_RIGHT="$SIZE - $VSIZE"
	printf "%s%${NEED_RIGHT}s" "$V" ''
}

function printCol() {
	local I
	for I in $(seq 1 $#); do
		local V="${!I}"
		local SIZE=${FIELD_SIZE_ARR[$I]}
		pad "$SIZE" "$V"
	done
	echo ''
}

mapfile -t LINES < "$FSTAB"
for LINE in "${LINES[@]}"; do
	if [[ "$LINE" = '' ]] || [[ "$LINE" = '#'* ]]; then
		continue
	fi

	read -r -a FIELDS <<< $LINE
	updateSize "${FIELDS[@]}"
done

CONTENT=''
for LINE in "${LINES[@]}"; do
	if [[ "$LINE" = '' ]] || [[ "$LINE" = '#'* ]]; then
		CONTENT+="$LINE"
	else
		read -r -a FIELDS <<< $LINE
		CONTENT+="$(printCol "${FIELDS[@]}")"
	fi
	CONTENT+=$'\n'
done
CONTENT=$(
	echo "$CONTENT" \
		| tr '\n' '\0' \
		| sed 's/^[[:space:]]+|[[:space:]]+$//g' \
		| sed 's/^\0|\0$//g' \
		| tr '\0' '\n'
)

if [[ "$CONTENT" == "$(< "$FSTAB")" ]]; then
	echo "Nothing changed"
else
	echo "$CONTENT" > "$FSTAB"
	echo -e "New fstab:\e[2m"
	cat "$FSTAB"
	echo -e "\e[0m"
fi
