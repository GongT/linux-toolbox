#!/bin/sh

emit 'export SUDO=$(is_root && echo ""|| echo "sudo ")'

emit "# shortcuts.sh"
emit_file shortcuts.sh

emit "# utils.sh"
emit_file utils.sh
