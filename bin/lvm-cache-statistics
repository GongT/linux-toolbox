#!/usr/bin/env bash

set -Eeuo pipefail

getw() { wc -L <<< "$1"; }

declare -ia FIELD_SIZE_ARR=()
function updateSize() {
	local I
	for I in $(seq 1 $#); do
		local V="${!I}"
		local -i SIZE
		SIZE="$(getw "$V") + 1"
		if [[ ${FIELD_SIZE_ARR[$I]:-0} -lt $SIZE ]]; then
			# echo "UpdateSize: $I -> $SIZE ($V)"
			FIELD_SIZE_ARR[$I]=$SIZE
		fi
	done
}

function padright() {
	local V="$2"
	local -i SIZE="$1" VSIZE
	VSIZE=$(getw "$V")
	printf "%$((SIZE - VSIZE))s%s" '' "$V"
}
function padleft() {
	local V="$2"
	local -i SIZE="$1" VSIZE
	VSIZE=$(getw "$V")
	local -i NEED_RIGHT="$SIZE - $VSIZE"
	printf "%s%${NEED_RIGHT}s" "$V" ''
}

function printLine() {
	local I
	for I in $(seq 1 $#); do
		local align=${COL_ALIGNS[$I]}
		local V="${!I}"
		local SIZE=${FIELD_SIZE_ARR[$I]}
		"pad${align}" "$SIZE" "$V"
	done
	echo ''
}

function percent() {
	if [[ "$2" -eq 0 ]]; then
		echo '-'
	else
		echo "scale=2;100*($1/$2)" | bc -l
	fi
}

FIELDS=lv_name,vg_name,lv_size,metadata_percent,cache_used_blocks,cache_total_blocks,cache_dirty_blocks,cache_read_hits,cache_read_misses,cache_write_hits,cache_write_misses

mapfile -t JSONS < <(
	lvs --noheadings \
		--units T \
		--reportformat json \
		--select 'cache_mode!=""' \
		-o "$FIELDS" \
		| jq -r -M -c '.report[0].lv[]'
)

declare -a COL_ALIGNS=('' 'left' 'right' 'right' 'right' 'right' 'left' 'right' 'right')
declare -a HEADER_LINE=('名称    ' '  容量' '    元数据' '    脏块量' '    缓存利用率' '总缓存  ' '   读取命中率' '   写入命中率')
declare -a WORKING_LINE=()
function parseLine() {
	for var; do
		# echo "$var"
		local -r "$var"
	done

	WORKING_LINE=()
	WORKING_LINE+=("$vg_name/$lv_name")
	WORKING_LINE+=(" $lv_size ")
	WORKING_LINE+=(" $metadata_percent% ")
	WORKING_LINE+=("  $(percent "$cache_dirty_blocks" "$cache_total_blocks")% ")
	WORKING_LINE+=(" $(percent "$cache_used_blocks" "$cache_total_blocks")% ")
	WORKING_LINE+=(" $cache_total_blocks")
	WORKING_LINE+=("  $(percent "$cache_read_hits" $((cache_read_hits + cache_read_misses)))%")
	WORKING_LINE+=("$(percent "$cache_write_hits" $((cache_write_hits + cache_write_misses)))%")
}

updateSize "${HEADER_LINE[@]}"
for JSON in "${JSONS[@]}"; do
	# echo $JSON
	mapfile -t vars < <(echo "$JSON" | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")[]')
	parseLine "${vars[@]}"
	updateSize "${WORKING_LINE[@]}"
done

printLine "${HEADER_LINE[@]}"
for JSON in "${JSONS[@]}"; do
	mapfile -t vars < <(echo "$JSON" | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")[]')
	parseLine "${vars[@]}"
	printLine "${WORKING_LINE[@]}"
done
