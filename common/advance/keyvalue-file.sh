function keyvalue-file() {
	if [[ ! "$1" ]]; then
		echo "Usage:
	Set value:    keyvalue-file filePath SOME_VAR new_value
	Unset value:  keyvalue-file filePath SOME_VAR
" >&2
		return 1
	fi

	local -r FILE=$1 NAME=$2 VALUE=$3

	if [[ "$VALUE" ]]; then
		if [[ -e "$FILE" ]] && grep -q --fixed-strings "$NAME=$VALUE" "$FILE"; then
			return
		fi
		echo "$NAME=$VALUE" >> "$FILE"
	else
		if [[ -e "$FILE" ]]; then
			sed -i "/^${NAME}=/d" "$FILE"
		fi
	fi
}
