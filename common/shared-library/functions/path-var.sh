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
	load)
		while IFS= read -r line; do
			list add PATH "${line}"
		done <"$OPDIR"
		;;
	*)
		cat <<-'HELP' >&2
			$PATH environment edit
			add:         path-var add /some/path
			prepend:     path-var prepend
			add:         path-var add ./resolve/to/absolte/path
			add:         path-var add-rel ./always/relative/path
			add file:    path-var load /path/to/file
			delete:      path-var del /some/path
			has:         path-var has /some/path
			normalize:   path-var normalize
			dump:        path-var dump
		HELP
		return 1
		;;
	esac
}

if [[ -e /etc/profile.d/path-var.lst ]]; then
	path-var load /etc/profile.d/path-var.lst
elif [[ $EUID -eq 0 ]]; then
	touch /etc/profile.d/path-var.lst
	chmod 666 /etc/profile.d/path-var.lst
fi
if [[ -e ~/.config/path-var.lst ]]; then
	path-var load ~/.config/path-var.lst
else
	touch ~/.config/path-var.lst
fi
