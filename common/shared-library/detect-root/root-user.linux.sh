function is_root() {
	[[ $UID -eq 0 ]]
}
export SUDO=$(is_root && echo "" || echo "sudo --preserve-env ")
if is_root; then
	_SUDO=()
else
	_SUDO=(sudo --preserve-env)
fi
declare -ar _SUDO

function _is_file_writable() {
	local FILE=$1

	if [[ -e $FILE ]]; then
		[[ -w $FILE ]]
	else
		local DIR
		DIR=$(dirname "$FILE")
		[[ -w $DIR ]]
	fi
}

function write_file() {
	local FILE=$1 CONTENT=$2
	if _is_file_writable "$FILE"; then
		printf "%s\n" "$CONTENT" >"$FILE"
	else
		printf "%s\n" "$CONTENT" | "${_SUDO[@]}" tee "$FILE" >/dev/null
	fi
}

function write_file_if_changed() {
	local FILE=$1 CONTENT=$2
	local CUR_CONTENT=""
	if [[ -e $FILE ]]; then
		CUR_CONTENT=$(cat "$FILE")
	fi

	if [[ "$CUR_CONTENT" != "$CONTENT" ]]; then
		write_file "$FILE" "$CONTENT"
	fi
}
