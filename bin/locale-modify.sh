#!/usr/bin/env bash

set -Eeuo pipefail

SECTIONS=(CTYPE NUMERIC TIME COLLATE MONETARY MESSAGES PAPER NAME ADDRESS TELEPHONE MEASUREMENT IDENTIFICATION)

function copy_section() {
	local SECTION=$1 FROM=$2
	echo "COPY $SECTION FROM LOCALE $FROM"
	echo "$SECTION"
	echo "copy \"$FROM\""
	echo "END $SECTION"

	
}

T=$(mktemp)
locale >"$T"
set -a
source "$T"
set +a
unlink "$T"

EDITOR=${EDITOR:-vim}

echo 'comment_char %'
echo 'escape_char /'

LCDEF=${LANG:-C.UTF-8}

if [[ ${LC_ALL:-} ]]; then
	for LCVAR_NAME in "${SECTIONS[@]}"; do
		copy_section "LC_$LCVAR_NAME" "$LC_ALL"
	done
else
	for LCVAR_NAME in "${SECTIONS[@]}"; do
		LCVAR_NAME="LC_$LCVAR_NAME"
		copy_section "$LCVAR_NAME" "${!LCVAR_NAME:-$LCDEF}"
	done
fi
