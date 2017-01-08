#!/bin/sh

if [ -e "/bin/cygpath.exe" ]; then
    emit 'alias is_root=/bin/false'
    emit 'export SUDO=""'
else
    emit "alias is_root='[ \"$(id -u)\" -eq 0 ]'"
    emit 'export SUDO=$(is_root && echo ""|| echo "sudo ")'
fi

emit "# shortcuts.sh"
emit_file shortcuts.sh

emit "# utils.sh"
emit_file utils.sh
