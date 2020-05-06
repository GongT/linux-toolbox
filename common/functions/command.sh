function find_command() {
	env sh --noprofile --norc -c "command -v \"$@\"" -- "$1"
}
function command_exists() {
	find_command "$1" &>/dev/null
}
