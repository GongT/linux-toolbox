#!/bin/sh

emit "#!/bin/bash"
emit "export MY_SCRIPT_ROOT='${INSTALL_SCRIPT_ROOT}'"

emit_stdin << 'INIT_SCRIPT'

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
	which "$@" &>/dev/null
}

INIT_SCRIPT
