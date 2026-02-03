function __FILE__() {
	echo "$(realpath "${BASH_SOURCE[0]}")"
}
function __DIR__() {
	echo "$(dirname $(realpath "${BASH_SOURCE[0]}"))"
}

function ensure_file_exists() {
	local FILE="$1"
	if ! [[ -f $FILE ]]; then
		mkdir -p "$(dirname "$FILE")"
		touch "$FILE"
	fi
}

function is_file_need_newline() {
	local FILE="$1"
	if ! [[ -f $FILE ]]; then
		return 1
	fi
	if [[ $(wc -c <"$FILE") -eq 0 ]]; then
		return 1
	fi
	is_file_ending_newline "$FILE"
}

function is_file_ending_newline() {
	local FILE="$1"
	test "$(tail -c 1 "$FILE" | wc -l)" -eq 0
}
function is_variable_ending_newline() {
	local VAR="$1"
	test "$(tail -c 1 <<<"$VAR" | wc -l)" -eq 0
}

function callstack() {
	local -i SKIP=${1-1}
	local -i i
	for i in $(seq $SKIP $((${#FUNCNAME[@]} - 1))); do
		if [[ ${BASH_SOURCE[$((i + 1))]+found} == "found" ]]; then
			echo "  $i: ${BASH_SOURCE[$((i + 1))]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}()"
		else
			echo "  $i: ${FUNCNAME[$i]}()"
		fi
	done
}

__exit_hooks=()
function atexit() {
	__exit_hooks+=("$(printf "%q" "$@")")
}

function _exit_handle() {
	local RET=$?
	local hook
	for hook in "${__exit_hooks[@]}"; do
		eval "${hook}"
	done
	exit $RET
}
trap _exit_handle EXIT

function register_exit_handle() {
	function _print_callstack_if_error() {
		echo -ne "\e[0m"
		if [[ ${RET} -ne 0 ]]; then
			callstack
		fi
	}
	atexit "_print_callstack_if_error"
}

function grep_safe() {
	grep "$@" || [[ $? -eq 1 ]]
}
