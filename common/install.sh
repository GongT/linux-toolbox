#!/bin/sh

emit '#!/bin/bash'

emit_stdin <<- "BASH_TEST"
	case "$0" in
	*bash*)
		# is BASH, run it
		;;
	*)
		return # not using BASH
	esac
	
BASH_TEST

emit_stdin << "INTERACTIVE_TEST_A"
case "$-" in
*i*)
	# This shell is interactive
	;;
*)
INTERACTIVE_TEST_A
emit_file "special/vscode-server.sh"
emit_stdin << "INTERACTIVE_TEST_B"
	# This shell is not interactive
	return
esac

INTERACTIVE_TEST_B

emit_file "functions/prefix.sh"
emit "
if [[ \"\${MY_SCRIPT_ROOT+found}\" != 'found' ]]; then
	declare -xr MY_SCRIPT_ROOT='${INSTALL_SCRIPT_ROOT}'
fi
"
emit_file "functions/basic.sh"
source "${HERE}/functions/basic.sh"
register_exit_handle

emit_file "functions/append-file.sh"
emit_file "functions/terminal.sh"

emit_file "functions/command.sh"
source "${HERE}/functions/command.sh"

if [[ -e "/bin/cygpath.exe" ]]; then
	emit_file "functions/root-user.cygwin.sh"
else
	emit_file "functions/root-user.linux.sh"
fi

emit_file "advance/environment-file.sh"
emit_file "advance/prompt-command.sh"

emit_file "advance/list.sh"
emit_file "advance/path-var.sh"
emit "path-var add /usr/local/bin"

emit_file "bash-config/exclude-list-dll.sh"
emit_file "bash-config/history.sh"

emit_file "advance/machine-name.sh"
