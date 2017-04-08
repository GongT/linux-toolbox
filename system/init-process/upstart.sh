#!/bin/sh

emit "export INIT_PROCESS=upstart"
export INIT_PROCESS=upstart

emit_alias_sudo "service"

emit_stdin << 'SERVICE_SCRIPT'
SERVICE_BIN=$(which service 2>/dev/null)
if [ $? -ne 0 ]; then
	die "no 'service' executable"
fi

function service { # name action
	if [ -z "$1" ]; then
		${SERVICE_BIN} "$@"
		echo
	elif [ "$2" = "enable" ]; then
		if [ ! -e "/etc/init/$1.conf" ]; then
			echo "unknown service $1" >&2
			return 1
		fi
		
		if [ -e "/etc/init/$1.override" ]; then
			if ! grep -qE '^manual$' "/etc/init/$1.override" ; then
				return 0
			fi
			
			local CONTENT=$(<"/etc/init/$1.override")
			echo "${CONTENT}" | grep -vE '^manual$' | sudo tee "/etc/init/$1.override" >/dev/null
			
			if [ $? -eq 0 ]; then
				echo "set $1 to auto" >&2
			else
				echo "failed to set $1 to auto" >&2
				return 1
			fi
		fi
	elif [ "$2" = "disable" ]; then
		if [ ! -e "/etc/init/$1.conf" ]; then
			echo "unknown service $1" >&2
			return 1
		fi
		
		if [ -e "/etc/init/$1.override" ]; then
			if grep -qE '^manual$' "/etc/init/$1.override" ; then
				return 0
			fi
		fi
		echo manual | sudo tee "/etc/init/$1.override" >/dev/null
		
		if [ $? -eq 0 ]; then
			echo "set $1 to manual" >&2
		else
			echo "failed to set $1 to manual" >&2
			return 1
		fi
	else
		${SERVICE_BIN} "$@"
		echo
	fi
}
SERVICE_SCRIPT
