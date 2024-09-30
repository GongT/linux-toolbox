function find_command() {
	PATH="/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin" command -v "$@" 2>/dev/null
}
function command_exists() {
	find_command "$1" &>/dev/null
}

function _find_command() {
	local PATH="$PATH"
	path-var del "$MY_SCRIPT_ROOT/bin"
	path-var del "$MY_SCRIPT_ROOT/.bin"
	find_command "$@"
}

function _command_exists() {
	local PATH="$PATH"
	path-var del "$MY_SCRIPT_ROOT/bin"
	path-var del "$MY_SCRIPT_ROOT/.bin"
	command_exists "$@"
}
