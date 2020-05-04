#!/bin/sh

function path-var() {
	local ACTION="$1"
	local OPDIR="$2"
	
	case $1 in
		del)
			list del PATH "${OPDIR}"
			if [[ "${OPDIR:0:1}" != "/" ]]; then
				list del PATH "$(realpath -m "${OPDIR}")"
			fi
		;;
		add)
			if [[ "${OPDIR:0:1}" != "/" ]]; then
				OPDIR=$(realpath -m "${OPDIR}")
			fi
		;&
		add-rel)
			list add PATH "${OPDIR}"
		;;
		dump)
			list dump PATH
		;;
		*)
			echo '

$PATH environment edit
add:    path-var add /some/path
add:    path-var add ./resolve/to/absolte/path
add:    path-var add-rel ./always/relative/path
delete: path-var del /some/path
has:    path-var has /some/path
dump:   path-var dump

' >&2
			return 1
		;;
	esac
}
