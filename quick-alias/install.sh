#!/bin/sh

emit 'export SUDO=$(is_root && echo ""|| echo "sudo ")'

emit "# commands.sh"
emit_file commands.sh

emit "# shortcuts.sh"
emit_file shortcuts.sh

emit "# utils.sh"
emit_file utils.sh
