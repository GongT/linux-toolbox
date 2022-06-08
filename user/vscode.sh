if command -v run-windows &>/dev/null; then
	if run-windows command_exists code.cmd; then
		alias code="run-cygpath code.cmd"
		export EDITOR='run-cygpath code.cmd --wait'
	elif run-windows command_exists code-insiders.cmd; then
		alias code="run-cygpath code-insiders.cmd"
		export EDITOR='run-cygpath code-insiders.cmd --wait'
	fi
elif [[ $PATH == *"/.vscode-server/"* ]]; then
	_VSCODEBIN="code"
	_VSCODEBINPATH=$(path-var dump | grep --fixed-strings '/.vscode-server/')
	export EDITOR='code --wait'
elif [[ $PATH == *"/.vscode-server-insiders/"* ]]; then
	_VSCODEBIN="code-insiders"
	_VSCODEBINPATH=$(path-var dump | grep --fixed-strings '/.vscode-server-insiders/')
	export EDITOR='code-insiders --wait'
fi

if [[ ${_VSCODEBIN+found} == found ]] && [[ ${_VSCODEBINPATH+found} == found ]] && ! command_exists "code"; then
	proxy on &>/dev/null

	OPATH=$PATH

	for i in "$_VSCODEBINPATH/"*; do
		PATH+=":$i/"
	done

	if command_exists "$_VSCODEBIN"; then
		P=$(find_command "$_VSCODEBIN")
		cat <<-EOF >"$_VSCODEBINPATH/code"
			#!/usr/bin/env bash

			set -Eeuo pipefail

			exec '$P' "\$@"
		EOF
		chmod a+x "$_VSCODEBINPATH/code"
		unset P
	else
		echo "failed find vscode binary" >&2
		path-var dump
	fi

	PATH=$OPATH
	unset OPATH i
fi
unset _VSCODEBIN _VSCODEBINPATH
