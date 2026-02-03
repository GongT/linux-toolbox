function is_file_writable() {
	local FILE=$1

	if [[ -e $FILE ]]; then
		[[ -w $FILE ]]
	else
		DIR=$(find_exists_parent "$FILE")
		[[ -w $DIR ]]
	fi
}

function find_exists_parent() {
	local FILE=$1
	while [[ ! -e $FILE ]]; do
		FILE=$(dirname "$FILE")
	done
	echo "$FILE"
}

LAST_FILE_CHANGED=no
function write_file() {
	local SUDO=no
	if [[ $1 == --sudo ]]; then
		shift
		SUDO=yes
	fi

	local FILE=$1 CONTENT=$2
	if [[ -L $FILE ]]; then
		if [[ -w $FILE ]]; then
			unlink "$FILE"
		else
			sudo unlink "$FILE"
		fi
	fi

	if ! is_variable_ending_newline "$CONTENT" ; then
		CONTENT+=$'\n'
	fi

	if [[ $SUDO == "yes" ]] && is_file_writable "$FILE"; then
		mkdir -p "$(dirname "$FILE")"
		printf "%s\n" "$CONTENT" >"$FILE"
	else
		sudo mkdir -p "$(dirname "$FILE")"
		printf "%s\n" "$CONTENT" | sudo tee "$FILE" >/dev/null
	fi
	LAST_FILE_CHANGED=yes
}

function write_file_if_changed() {
	local SUDO=()
	if [[ $1 == --sudo ]]; then
		shift
		SUDO=("--sudo")
	fi
	local FILE=$1 CONTENT=$2
	local CUR_CONTENT=""
	if [[ -e $FILE ]]; then
		CUR_CONTENT=$(cat "$FILE")
	fi

	if [[ $CUR_CONTENT != "$CONTENT" ]]; then
		write_file "${SUDO[@]}" "$FILE" "$CONTENT"
	else
		LAST_FILE_CHANGED=no
	fi
}
