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

mkdir -p /etc/ssh/ssh_config.d
echo "SendEnv DISPLAY" > /etc/ssh/ssh_config.d/80-linux-toolbox.conf
