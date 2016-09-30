#!/bin/sh

emit "export INIT_PROCESS=rhel-sysv"
export INIT_PROCESS=rhel-sysv

emit_alias_sudo "service"
emit_alias_sudo "chkconfig"

emit_stdin << 'SERVICE_SCRIPT'
SERVICE_BIN=$(which service 2>/dev/null)
if [ $? -ne 0 ]; then
	die "no 'service' executable"
fi

function service { # name action
	if [ "$2" == "enable" ]; then
		chkconfig --add $1
	elif [ "$2" == "disable" ]; then
		chkconfig --del $1
	else
		${SERVICE_BIN} "$@"
	fi
}
SERVICE_SCRIPT
