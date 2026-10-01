# 输出函数，此文件不应依赖任何非builtin

if declare -f die >/dev/null 2>&1; then
	# duplicate "source" protection
	return
fi

__OUTPUT_INDENT=''

indent() {
	__OUTPUT_INDENT+=$'    '
}

indent-() {
	__OUTPUT_INDENT=${__OUTPUT_INDENT%$'    '}
}

write() {
	local txt
	txt="$(_remove_empty_and_unescape "$@")"
	builtin printf "%s" "${__OUTPUT_INDENT}$txt" >&2
}

writeln() {
	local txt
	txt="$(_remove_empty_and_unescape "$@")"
	builtin printf "%s\n" "${__OUTPUT_INDENT}$txt" >&2
}

error() {
	local txt
	txt="$(_remove_empty_and_unescape "$@")"
	builtin printf "${__OUTPUT_INDENT}\e[38;5;9m%s\e[0m\n" "$txt" >&2
}

warning() {
	local txt
	txt="$(_remove_empty_and_unescape "$@")"
	builtin printf "${__OUTPUT_INDENT}\e[38;5;11m%s\e[0m\n" "$txt" >&2
}

info() {
	local txt
	txt="$(_remove_empty_and_unescape "$@")"
	builtin printf "${__OUTPUT_INDENT}\e[38;5;14m%s\e[0m\n" "$txt" >&2
}

header() {
	local txt
	txt="$(_remove_empty_and_unescape "$@")"
	builtin printf "\n\e[48;5;14;1m   ${__OUTPUT_INDENT} %s    \e[0m\n" "$txt" >&2
}

success() {
	local txt
	txt="$(_remove_empty_and_unescape "$@")"
	builtin printf "${__OUTPUT_INDENT}\e[38;5;10m%s\e[0m\n" "$txt" >&2
}

debug() {
	local txt
	txt="$(_remove_empty_and_unescape "$@")"
	builtin printf "${__OUTPUT_INDENT}\e[2m%s\e[0m\n" "$txt" >&2
}

debug_exec() {
	debug "exec: $*" 
	"$@"
}

die() {
	local txt
	txt="$(_remove_empty_and_unescape "$@")"
	builtin printf "\n\n\e[1;48;5;9m [ERROR] \e[0m %s\n" "$txt" >&2
	builtin exit 1
}

_remove_empty_and_unescape() {
	local args=()
	for arg; do
		if [[ -n $arg ]]; then
			args+=("$arg")
		fi
	done

	builtin printf "%b" "${args[*]}"
}

ok() {
	writeln "$@" "- \e[38;5;10mOK!\e[0m"
}
