function __FILE__() {
	echo "$(realpath "${BASH_SOURCE[0]}")"
}
function __DIR__() {
	echo "$(dirname $(realpath "${BASH_SOURCE[0]}"))"
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

function callstack() {
	local -i SKIP=${1-1}
	local -i i
	for i in $(seq $SKIP $((${#FUNCNAME[@]} - 1))); do
		if [[ "${BASH_SOURCE[$((i + 1))]+found}" = "found" ]]; then
			echo "  $i: ${BASH_SOURCE[$((i + 1))]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}()"
		else
			echo "  $i: ${FUNCNAME[$i]}()"
		fi
	done
}

function _exit_handle() {
	RET=$?
	echo -ne "\e[0m"
	if [[ "$RET" -ne 0 ]]; then
		callstack
	fi
	exit $RET
}

function register_exit_handle() {
	trap _exit_handle EXIT
}

function grep_safe() {
	grep "$@" || [[ $? -eq 1 ]]
}
