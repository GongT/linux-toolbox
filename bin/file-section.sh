#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
	echo "$(basename "$0") FILE <section name> <content text>
             FILE --delete|-d <section name>
             FILE --get|-g <section name>
	" >&2
}

if [[ $# -ne 3 ]]; then
	usage
	exit 1
fi

declare -r FILE=$1
shift

if [[ -t 2 ]]; then
	debug() {
		echo "$*" >&2
	}
else
	debug() {
		:
	}
fi

init() {
	SECTION_START="### SECTION_START: ${SECTION_NAME} ###"
	SECTION_START_RE=$(escape-regex "$SECTION_START")
	SECTION_END="### SECTION_END:   ${SECTION_NAME} ###"
	SECTION_END_RE=$(escape-regex "$SECTION_END")
}

get_value() {
	if ! [[ -e $FILE ]]; then
		return 0
	fi
	sed -n "/${SECTION_START_RE}/,/${SECTION_END_RE}/{//!p}" "${FILE}"
}

if [[ $1 == "-g" ]] || [[ $1 == "--get" ]]; then
	declare -r SECTION_NAME=$2
	init
	get_value
elif [[ $1 == "-d" ]] || [[ $1 == "--delete" ]]; then
	declare -r SECTION_NAME=$2
else
	declare -r SECTION_NAME=$1
	init

	EXCEPT_CONTENT="$2"
	CURRENT_CONTENT=$(get_value)
	if ! [[ "$CURRENT_CONTENT" ]]; then
		debug "create section"
		ensure-blank-ending "$FILE"
		{
			echo "$SECTION_START"
			echo "$EXCEPT_CONTENT"
			echo "$SECTION_END"
		} >>"$FILE"
	elif [[ $EXCEPT_CONTENT != "$CURRENT_CONTENT" ]]; then
		debug "content replace"
		BEFORE=$(sed "/$SECTION_START_RE/q" "$FILE")
		AFTER=$(sed -n "/$SECTION_END_RE/,\$p" "$FILE")

		{
			echo "$BEFORE"
			echo "$EXCEPT_CONTENT"
			echo "$AFTER"
		} >"$FILE"
	else
		debug "content exists"
		exit 0
	fi
fi
