function find_command() {
	PATH="${_ORIG_PATH:-$PATH}" command -v "$@" 2>/dev/null
}
function command_exists() {
	find_command "$1" &>/dev/null
}
