#!/bin/sh

emit "export INIT_PROCESS=systemd"
export INIT_PROCESS=systemd

emit "# systemctl-journalctl.sh"
emit_file bin/systemctl-journalctl.sh

emit_alias_sudo "networkctl"
emit 'complete -o default -o nospace -F _systemctl s
source /usr/share/bash-completion/completions/systemctl
alias s="${SUDO}systemctl"'
