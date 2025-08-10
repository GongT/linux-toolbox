#!/usr/bin/env bash

function path-var() {
	local ACTION="${1:-}"
	local OPDIR="${2:-}"
	local SEP=':'

	case $ACTION in
	del)
		list del PATH "${OPDIR}"
		if [[ ${OPDIR:0:1} != "/" ]]; then
			list del PATH "$(realpath -m "${OPDIR}")"
		fi
		;;
	add)
		if [[ ${OPDIR:0:1} != "/" ]]; then
			OPDIR=$(realpath -m "${OPDIR}")
		fi
		;&
	add-rel)
		list add PATH "${OPDIR}"
		;;
	prepend)
		if [[ ${OPDIR:0:1} != "/" ]]; then
			OPDIR=$(realpath -m "${OPDIR}")
		fi
		list del PATH "${OPDIR}"
		list prepend PATH "${OPDIR}"
		;;
	has)
		list has PATH
		;;
	dump)
		list dump PATH
		;;
	normalize)
		list dedup PATH
		;;
	*)
		cat <<-'HELP' >&2
			$PATH environment edit
			add:         path-var add /some/path
			prepend:     path-var prepend
			add:         path-var add ./resolve/to/absolte/path
			add:         path-var add-rel ./always/relative/path
			delete:      path-var del /some/path
			has:         path-var has /some/path
			normalize:   path-var normalize
			dump:        path-var dump
		HELP
		return 1
		;;
	esac
}
