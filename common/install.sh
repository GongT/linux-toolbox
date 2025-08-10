#!/usr/bin/env bash

emit "if [[ -z \${MY_LIBEXEC-} ]]; then
	declare -r MY_LIBEXEC=$MY_LIBEXEC
fi"

emit_file "functions/prefix.sh"

install_script shared-library

emit_file "functions/terminal.sh"

emit_file "advance/environment-file.sh"
emit_file "advance/keyvalue-file.sh"
emit_file "advance/prompt-command.sh"

emit "path-var add /usr/local/bin"

emit_file "bash-config/exclude-list-dll.sh"
emit_file "bash-config/history.sh"

emit_file "advance/machine-name.sh"

if [[ $(systemd-detect-virt) == 'wsl' ]]; then
	emit_file "advance/path.wsl.sh"
fi
emit 'path-var normalize
export PATH
'

if is_root ; then
	mkdir -p /usr/local/libexec/vscode-wrap
	cp "${HERE}/vscode/vscode-alternative-shell" /usr/local/libexec/vscode-wrap
fi
