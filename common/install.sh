#!/bin/sh

emit "#!/bin/sh"
emit "export MY_SCRIPT_ROOT='${INSTALL_SCRIPT_ROOT}'"

emit_stdin << 'INIT_SCRIPT'

function __FILE__ {
	echo 'realpath $BASH_SOURCE'
}
function __DIR__ {
	echo 'dirname `realpath $BASH_SOURCE`'
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

emit 'PATH="$PATH:./node_modules/.bin"'
