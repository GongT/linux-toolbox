#!/bin/sh

emit '#!/bin/bash

if [ "$0" != "-bash" ] && [ "$0" != "bash" ]; then
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

function command_exists {
	command -v $1 &>/dev/null
}

'

source ${TARGET} || die "start fail, bad header: ${TARGET}"
