function append_text_file_section() {
	local FILE="$1"
	local COMMENT_TYPE="$2"
	local MARKUP="$3"
	local CONTENT="${4}"

	ensure_file_exists "$FILE"

	local COMMENT="${COMMENT_TYPE}${COMMENT_TYPE}${COMMENT_TYPE}"
	local COMMENT_START="${COMMENT} ${MARKUP}"
	local COMMENT_END="${COMMENT} END ${MARKUP}"
	local SED_PATTERN="/^${COMMENT_START}/,/^${COMMENT_END}$/"

	CONTENT="${CONTENT//'\'/'\\'}"
	CONTENT="${CONTENT//$'\n'/'\n'}"

	if [[ $(sed -n "${SED_PATTERN}p" "$FILE" | wc -l) -eq 0 ]]; then
		if is_file_need_newline "$FILE"; then
			echo "" >> "$FILE"
		fi
		echo "${COMMENT_START}
${CONTENT}
${COMMENT_END}" >> "$FILE"
	else
		sed -i -e "${SED_PATTERN}c\\" -e "${COMMENT_START}\n${CONTENT}\n${COMMENT_END}" "$FILE"
	fi
}

function append_text_file_line() {
	local FILE="$1"
	local COMMENT_TYPE="$2"
	local MARKUP="$3"
	local CONTENT="$4"

	if [[ "$CONTENT" == *$"\n"* ]]; then
		echo "[append_text_file_line] Error: content must have only one line" >&2
		return 1
	fi

	ensure_file_exists "$FILE"

	local PATTERN="^${COMMENT_TYPE}${COMMENT_TYPE} ${MARKUP}$"
	if grep -q "$PATTERN" "$FILE"; then
		local SED_PATT="${PATTERN//\//\\/}"
		sed -i "/$SED_PATT/{
			a\\
$CONTENT
			n
			d
		}" "$FILE"
	else
		if is_file_need_newline "$FILE"; then
			echo "" >> "$FILE"
		fi
		{
			echo "${COMMENT_TYPE}${COMMENT_TYPE} ${MARKUP}"
			echo "$CONTENT"
		} >> "$FILE"
	fi
}
