#!/usr/bin/env bash

emit_file "functions/prefix.sh"

emit_stdin <<INTERACTIVE_TEST_A
case "\$-" in
*i*)
	# This shell is interactive
	export USERNAME=''
	unset USERNAME
	;;
*)
	# This shell is not interactive
	return
esac
INTERACTIVE_TEST_A

declare -f die callstack _exit_handle | emit_stdin
emit "
function sample_show_callstack_on_error() {
	trap _exit_handle EXIT	
}
"

emit "declare -xr MY_SCRIPT_ROOT='${MY_SCRIPT_ROOT}'"
emit_file "functions/basic.sh"

emit_file "functions/append-file.sh"
emit_file "functions/terminal.sh"

emit_file "functions/command.sh"

if [[ -e "/bin/cygpath.exe" ]]; then
	emit_file "functions/root-user.cygwin.sh"
else
	emit_file "functions/root-user.linux.sh"
fi

emit_file "advance/environment-file.sh"
emit_file "advance/keyvalue-file.sh"
emit_file "advance/prompt-command.sh"

emit_file "advance/list.sh"
emit_file "advance/path-var.sh"
emit "path-var add /usr/local/bin"

emit_file "bash-config/exclude-list-dll.sh"
emit_file "bash-config/history.sh"

emit_file "advance/machine-name.sh"

source "${HERE}/functions/basic.sh"
source "${HERE}/functions/append-file.sh"
source "${HERE}/advance/list.sh"
source "${HERE}/advance/path-var.sh"
source "${HERE}/functions/command.sh"
register_exit_handle

emit 'path-var normalize
export PATH
'

mkdir -p /usr/local/libexec/vscode-wrap
cp "${HERE}/vscode/vscode-alternative-shell" /usr/local/libexec/vscode-wrap

path-var del "$MY_SCRIPT_ROOT/.bin"

