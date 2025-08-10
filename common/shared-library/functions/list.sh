#!/bin/bash

function list() {
	if [[ ! ${SEP:-} ]]; then
		local SEP=':'
	fi
	function _list_exists() {
		[[ "${SEP}${TARGET_VAR_VALUE}${SEP}" == *"${SEP}$1${SEP}"* ]]
	}
	function _list_split() {
		echo "${TARGET_VAR_VALUE}" | sed "s/${SEP}/\n/g"
	}

	local RET=0
	local ACTION="${1:-}"
	local TARGET_VAR="${2:-}"
	local VALUE="${3:-}"
	if [[ -n $TARGET_VAR ]]; then
		local TARGET_VAR_VALUE="${!TARGET_VAR:-}"
	fi

	case "$ACTION" in
	has)
		_list_exists "$VALUE"
		RET=$?
		;;
	del)
		# echo "DELETE< $TARGET_VAR = ${!TARGET_VAR}">&2
		if _list_exists "$VALUE"; then
			TARGET_VAR_VALUE="${SEP}${TARGET_VAR_VALUE}${SEP}"
			TARGET_VAR_VALUE="${TARGET_VAR_VALUE/${SEP}$VALUE${SEP}/${SEP}}"
			TARGET_VAR_VALUE="${TARGET_VAR_VALUE:1:-1}"
			eval "$TARGET_VAR='${TARGET_VAR_VALUE}'"
		fi
		# echo "DELETE> $TARGET_VAR = ${!TARGET_VAR}">&2
		;;
	add)
		# echo "ADD< $TARGET_VAR = ${!TARGET_VAR}">&2
		if ! _list_exists "$VALUE"; then
			if [[ -n ${TARGET_VAR_VALUE} ]]; then
				TARGET_VAR_VALUE="${TARGET_VAR_VALUE}${SEP}${VALUE}"
			else
				TARGET_VAR_VALUE="$VALUE"
			fi
			eval "$TARGET_VAR='${TARGET_VAR_VALUE}'"
		fi
		# echo "ADD> $TARGET_VAR = ${!TARGET_VAR}">&2
		;;
	prepend)
		# echo "PREPEND< $TARGET_VAR = ${!TARGET_VAR}">&2
		if ! _list_exists "$VALUE"; then
			if [[ -n ${TARGET_VAR_VALUE} ]]; then
				TARGET_VAR_VALUE="${VALUE}${SEP}${TARGET_VAR_VALUE}"
			else
				TARGET_VAR_VALUE="$VALUE"
			fi
			eval "$TARGET_VAR='${TARGET_VAR_VALUE}'"
		fi
		# echo "PREPEND> $TARGET_VAR = ${!TARGET_VAR}">&2
		;;
	dump)
		_list_split
		;;
	size)
		_list_split | wc -l
		;;
	normalize)
		# echo "NORMALIZE< $TARGET_VAR = ${!TARGET_VAR}">&2
		local PVAL="$TARGET_VAR_VALUE"
		local NVAL=""
		local IFS=$'\n'
		for LINE in $(list dump PVAL); do
			list add NVAL "$LINE"
		done
		eval "$TARGET_VAR='${NVAL}'"
		# echo "NORMALIZE> $TARGET_VAR = ${!TARGET_VAR}">&2
		;;
	*)
		echo "

Unknown action: '$ACTION'
bash string list edit tool:
	add:      list add        SOME_VAR value
	add:      list prepend    SOME_VAR value
	delete:   list del        SOME_VAR value
	get size: list size       SOME_VAR
	has:      list has        SOME_VAR value
	dump:     list dump       SOME_VAR
environment:
	SEP:   delimiter, defaluts to :
" >&2
		RET=1
		;;
	esac
	unset -f _list_exists _list_split
	return $RET
}
