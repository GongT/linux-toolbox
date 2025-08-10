function find_command() {
	PATH="/usr/local/bin:/usr/bin" command -v "$@" 2>/dev/null
}
function command_exists() {
	find_command "$1" &>/dev/null
}
