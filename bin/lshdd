#!/usr/bin/env bash

set -Eeuo pipefail

ALIGN=left
function pad() {
	local V="$2"
	local -i SIZE="$1" VSIZE="${#V}"
	if [[ "$ALIGN" = right ]]; then
		printf "%${SIZE}s" "$V"
	elif [[ "$ALIGN" = center ]]; then
		local -i NEED_RIGHT="( $SIZE - $VSIZE ) / 2"
		SIZE="$SIZE - $NEED_RIGHT"
		printf "%${SIZE}s%${NEED_RIGHT}s" "$V" ''
	else
		local -i NEED_RIGHT="$SIZE - $VSIZE"
		printf "%s%${NEED_RIGHT}s" "$V" ''
	fi
}

function repeatString() {
	local -r string="${1}" numberToRepeat="${2}"
	local -r result="$(printf "%${numberToRepeat}s")"
	echo -ne "${result// /${string}}"
}

function append() {
	local -r OLDVAL=$1 VALUE=$2
	if [[ "${OLDVAL}" ]]; then
		echo "${OLDVAL}:${VALUE}"
	else
		echo "${VALUE}"
	fi
}
function isPartition() {
	local DEV=$1
	[[ -e "/sys/class/block/$DEV/partition" ]]
}
function getParentDevice() {
	local DEV=$1
	if isPartition "$DEV"; then
		local PARENT
		PARENT=$(dirname "$(readlink "/sys/class/block/$DEV")")
		if [[ -e "$PARENT/partition" ]]; then
			basename "$PARENT"
		else
			echo "$DEV"
		fi
	else
		echo "$DEV"
	fi
}
function findPartitions() {
	local DEV=$1 DIR
	DIR=$(readlink "/sys/class/block/$DEV")
	find "$DIR" -mindepth 1 -maxdepth 1 -name "${1}*" -type d
}

declare -A DEV_NAMES=()
function collectDevNames() {
	local LIST DEV FILE NAME
	mapfile -t LIST < <(
		find /dev/disk/by-id -mindepth 1 -maxdepth 1 -type l -not -name 'wwn-*' -not -name 'lvm-*' -not -name 'dm-*'
	)
	for FILE in "${LIST[@]}"; do
		DEV=$(readlink "$FILE")
		DEV=$(basename "$DEV")

		if isPartition "$DEV"; then
			continue
		fi

		NAME=$(basename "$FILE")
		NAME=${NAME#*-}

		DEV_NAMES[$DEV]=$NAME
		# echo "NAME: $DEV = ${DEV_NAMES[$DEV]}"
	done
}

declare -A DEV_SIZES=()
function collectDevSizes() {
	local LINES LINE_ARR DEV SZ
	mapfile -t LINES < <(cat /proc/partitions | tail -n+3 | grep -v ' dm-')
	for LINE in "${LINES[@]}"; do
		mapfile -t LINE_ARR < <(echo -n "$LINE" | awk '{print $3"\n"$4}')
		DEV=${LINE_ARR[1]}

		if isPartition "$DEV"; then
			continue
		fi

		SZ=$(("${LINE_ARR[0]}" / 1024 / 1024))
		if [[ "$SZ" -gt 1024 ]]; then
			DEV_SIZES[$DEV]="$(awk -v "SZ=$SZ" 'BEGIN { print  ( SZ / 1024 ) }')T"
		else
			DEV_SIZES[$DEV]="${SZ}G"
		fi

		# echo "SIZE: $DEV = ${DEV_SIZES[$DEV]} (${LINE_ARR[0]})"
	done
}

declare -A DEV_LVMPVS=()
function collectDevLvmpvs() {
	local LIST AB DEV PARENT
	mapfile -t LIST < <(pvs --sort vg_name --noheadings --options pv_name,vg_name)
	for LINE in "${LIST[@]}"; do
		mapfile -t AB < <(echo "$LINE" | awk '{print $1"\n"$2}')
		DEV="${AB[0]}"
		DEV=$(basename "$DEV")
		PARENT=$(getParentDevice "$DEV")

		if [[ "${DEV_LVMPVS["$PARENT"]:-}" ]]; then
			DEV_LVMPVS[$PARENT]+=",${AB[1]}"
		else
			DEV_LVMPVS[$PARENT]="${AB[1]}"
		fi
	done

	# local I
	# for I in "${!DEV_LVMPVS[@]}"; do
	# 	echo "LVM VG: $I = ${DEV_LVMPVS[$I]}"
	# done
}
declare -A DEV_LOCATION=()
function collectDevLocation() {
	local DEV LOC
	for DEV in "${!DEV_NAMES[@]}"; do
		LOC=$(basename "$(readlink "/sys/class/block/$DEV/device")")
		DEV_LOCATION[$DEV]="${LOC}"
		# echo "LOC: $DEV = ${DEV_LOCATION[$DEV]}"
	done
}

declare -A DEV_MOUNTS=()
function collectDevMounts() {
	local MOUNT_LINES LINE LINE_ARR SOURCE TARGET DEV PARENT
	mapfile -t MOUNT_LINES < <(cat /proc/mounts)
	for LINE in "${MOUNT_LINES[@]}"; do
		if ! [[ ${LINE} = /* ]]; then
			continue
		fi

		mapfile -t LINE_ARR < <(echo "$LINE" | awk '{print $1"\n"$2}')
		SOURCE="${LINE_ARR[0]}"
		TARGET="${LINE_ARR[1]}"

		if [[ "$SOURCE" = /dev/mapper/* ]]; then
			local DEVLIST

			mapfile -t DEVLIST < <(
				lvdisplay "$SOURCE" -m | grep "Physical volume" | sed 's/Physical volume//g' | sed 's/[[:space:]]//g'
			)

			for DEV in "${DEVLIST[@]}"; do
				if [[ "$DEV" = /dev/* ]]; then
					DEV=$(basename "$DEV")
					PARENT=$(getParentDevice "$DEV")
					DEV_MOUNTS[$PARENT]=$(append "${DEV_MOUNTS[$PARENT]:-}" "$TARGET")
				else
					echo -e "\e[38;5;9mUnknown physical volume: $DEV\n  $SOURCE $TARGET\e[0m" >&2
				fi
			done
		elif [[ "$SOURCE" = /dev/* ]]; then
			DEV=$(basename "$SOURCE")
			PARENT=$(getParentDevice "$DEV")
			DEV_MOUNTS[$PARENT]=$(append "${DEV_MOUNTS[$PARENT]:-}" "$TARGET")
		else
			echo -e "\e[38;5;9mUnknown mount: \n  $SOURCE $TARGET\e[0m" >&2
		fi
	done

	# local I
	# for I in "${!DEV_MOUNTS[@]}"; do
	# 	echo "MOUNTS: $I = ${DEV_MOUNTS[$I]}"
	# done
}

declare -a TABLE_HEAD=('Device' 'Location' 'ID' 'Size' 'Group' 'MountPoint')
PRINT_TABLE=no

declare -ia TABLE_SIZE=()
function updateTableSize() {
	local I
	for I in $(seq 1 $#); do
		local V="${!I}"
		local SIZE=${#V}
		if [[ ${TABLE_SIZE[$I]:-0} -lt $SIZE ]]; then
			# echo "UpdateSize: $I -> $SIZE"
			TABLE_SIZE[$I]=$SIZE
		fi
	done
}
function printLastCol() {
	local -r ALIGN=left
	local -r DATA="$1"
	local -i LAST_COL_NUM="${#TABLE_SIZE[@]}"
	if [[ "$DATA" = *$'\n'* ]]; then
		local LINES LINE I
		mapfile -t LINES < <(echo "$DATA")
		printCol "$LAST_COL_NUM" "${LINES[0]}"
		printNewLine
		for LINE in "${LINES[@]:1}"; do
			for ((I = 1; I < "$LAST_COL_NUM"; I++)); do
				printCol "$I" ""
			done
			printCol "$LAST_COL_NUM" "$LINE"
			printNewLine
		done
	else
		printCol "$LAST_COL_NUM" "$DATA"
		printNewLine
	fi
}
function printCol() {
	local INDEX="$1" CONTENT="$2"
	if [[ "$PRINT_TABLE" = yes ]]; then
		echo -n '| '
		pad "${TABLE_SIZE[$INDEX]}" "$CONTENT"
		echo -n ' '
	else
		echo "${TABLE_HEAD[$((INDEX - 1))]}: $CONTENT"
	fi
}
function printNewLine() {
	if [[ "$PRINT_TABLE" = yes ]]; then
		echo "|"
	else
		echo ""
	fi
}
function startTable() {
	local I
	echo -n "*"
	repeatString "-" "$((PAPER_WIDTH - 2))"
	echo "*"

	for I in "${!TABLE_HEAD[@]}"; do
		printCol "$((I + 1))" "${TABLE_HEAD[$I]}"
	done
	printNewLine

	echo -n "|"
	repeatString "=" "$((PAPER_WIDTH - 2))"
	echo "|"
}
function finalTable() {
	echo -n "*"
	repeatString "-" "$((PAPER_WIDTH - 2))"
	echo "*"
}
declare -i PAPER_WIDTH=0
function finalTableSize() {
	local size=$(stty size)
	local -i COLUMNS=${size#* }
	PAPER_WIDTH=$COLUMNS

	local -i I TOTAL=2
	for I in "${TABLE_SIZE[@]}"; do
		TOTAL+="$I + 3"
	done
	local -i LAST_COL="${COLUMNS} - $TOTAL - 2"

	# {
	# 	echo "COLUMNS: $COLUMNS"
	# 	for I in "${!TABLE_SIZE[@]}"; do
	# 		echo " - $I: ${TABLE_SIZE[$I]}"
	# 	done
	# 	echo "LAST_COL: $LAST_COL"
	# } >&2

	if [[ $LAST_COL -le 13 ]]; then
		PRINT_TABLE=no
		{
			echo "Can not print table, since your window is too small"
			echo -n "    columns: "
			for I in "${!TABLE_SIZE[@]}"; do
				echo -n "${TABLE_SIZE[$I]} "
			done
			echo
			echo "    need char: $TOTAL + 2"
			echo "    you have: ${COLUMNS}"
		} >&2
	else
		PRINT_TABLE=yes
		TABLE_SIZE+=("$LAST_COL")
	fi
}

function prepareTable() {
	local -i _MAX=${#TABLE_HEAD[@]}
	updateTableSize "${TABLE_HEAD[@]:0:$((_MAX - 1))}"
	for DEV in "${!DEV_NAMES[@]}"; do
		LOC="${DEV_LOCATION[$DEV]:-}"
		ID="${DEV_NAMES[$DEV]}"
		SIZE="${DEV_SIZES[$DEV]:-}"
		VGS="${DEV_LVMPVS[$DEV]:-}"
		updateTableSize "$DEV" "$LOC" "$ID" "$SIZE" "$VGS"
	done
	finalTableSize

	startTable
}

collectDevNames
collectDevSizes
collectDevLvmpvs
collectDevLocation
collectDevMounts
prepareTable
for DEV in "${!DEV_NAMES[@]}"; do
	ALIGN=center printCol 1 "$DEV"
	ALIGN=right printCol 2 "${DEV_LOCATION[$DEV]:-}"
	printCol 3 "${DEV_NAMES[$DEV]}"
	ALIGN=right printCol 4 "${DEV_SIZES[$DEV]:-}"
	printCol 5 "${DEV_LVMPVS[$DEV]:-}"
	MOUNTS="${DEV_MOUNTS[$DEV]:-}"
	if [[ "$MOUNTS" ]]; then
		MOUNTS="$(echo "${MOUNTS}" | sed 's/:/\n/g' | fold -w "${TABLE_SIZE[6]}" -c)"
	fi
	printLastCol "$MOUNTS"
done
finalTable
