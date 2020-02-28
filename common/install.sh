#!/bin/sh

emit '#!/bin/bash

if [[ -z "$__L_INST" ]]; then
	if [ "$0" != "-bash" ] && [ "$0" != "bash" ] && [ "$0" != "/bin/bash" ] && [ "$0" != "/usr/bin/bash" ]; then
		return
	fi
	case "$-" in
	*i*)
		# This shell is interactive
		;;
	*)
		# This shell is not interactive
		return
		;;
	esac

	if [[ -n "${LINUX_TOOLBOX_INITED}" ]]; then
		return
	fi
fi
LINUX_TOOLBOX_INITED=yes

if [[ ":$PATH:" != *":/usr/local/bin:"* ]] ; then
	export PATH+=:/usr/local/bin
fi
'

emit "export MY_SCRIPT_ROOT='${INSTALL_SCRIPT_ROOT}'"

emit '

function __FILE__ {
	echo "$(realpath "${BASH_SOURCE[0]}")"
}
function __DIR__ {
	echo "$(dirname $(realpath "${BASH_SOURCE[0]}") )"
}

function die {
	echo "" >&2
	echo "$@" >&2
	exit 1
}

function find_command() {
	env sh --noprofile --norc -c "command -v \"$@\"" -- "$1"
}
function command_exists() {
	find_command "$1" &>/dev/null
}

'

unset LINUX_TOOLBOX_INITED
__L_INST=yes
source ${TARGET} || die "start fail, bad header: ${TARGET}"
unset __L_INST LINUX_TOOLBOX_INITED
