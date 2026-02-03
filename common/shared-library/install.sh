#!/usr/bin/env bash

emit_file "functions/basic.sh"
emit_file "functions/append-file.sh"
emit_file "functions/write-file.sh"

emit_file "functions/list.sh"
emit_file "functions/path-var.sh"

emit_file "functions/command.sh"

if [[ -e "/bin/cygpath.exe" ]]; then
	emit_file "detect-root/root-user.cygwin.sh"
else
	emit_file "detect-root/root-user.linux.sh"
fi
