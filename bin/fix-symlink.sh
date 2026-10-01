#!/usr/bin/env bash

ACTION="${1-}"
shift

_print() {
	echo "$*" >&2
}

_printf() {
	local MSG="$1"
	shift
	printf "$MSG\n" "$@" >&2
}

usage() {
	local A="${ACTION}"
	if [[ -z $A ]]; then
		_print "用法: $0 <command> [<args>]"
		usage_all_commands
	else
		local FN="usage_${A}"
		if declare -f "$FN" >/dev/null; then
			_print "用法: $0 $A [<args>]"
			"$FN"
		else
			_printf "\e[31m未知命令: $A\e[0m"
			_print "用法: $0 $A [<args>]"
		fi
	fi
	exit "${1:-1}"
}

usage_all_commands() {
	_print "可用命令:"
	_print "  repair    通过查找同名文件，尝试修复符号链接"
}

usage_repair() {
	_print "用法: $0 $A [<args>]"

}

execute_repair() {
	echo "修复符号链接..."
}

case "$ACTION" in
repair)
	execute_repair "$@"
	;;
*)
	usage
	;;
esac
