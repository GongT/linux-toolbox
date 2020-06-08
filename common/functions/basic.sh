function __FILE__() {
	echo "$(realpath "${BASH_SOURCE[0]}")"
}
function __DIR__() {
	echo "$(dirname $(realpath "${BASH_SOURCE[0]}"))"
}

function die() {
	echo "" >&2
	echo "$@" >&2
	exit 1
}

function ensure_file_exists() {
	local FILE="$1"
	if ! [[ -f "$FILE" ]]; then
		mkdir -p "$(dirname "$FILE")"
		touch "$FILE"
	fi
}

function is_file_need_newline() {
	local FILE="$1"
	if ! [[ -f "$FILE" ]]; then
		return 1
	fi
	if [[ $(wc -c < "$FILE") -eq 0 ]]; then
		return 1
	fi
	is_file_ending_newline "$FILE"
}

function is_file_ending_newline() {
	local FILE="$1"
	test $(tail -c 1 "$FILE" | wc -l) -eq 0
}
