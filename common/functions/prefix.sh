#!/bin/bash

case "$0" in
*bash*)
	# is BASH, continue
	;;
*)
	return # not using BASH
	;;
esac

if [[ ${_INSTALL_LEVEL_+found} != "found" ]]; then
	if [[ ${LINUX_TOOLBOX_INITED:-no} == "yes" ]]; then
		return
	else
		declare -r LINUX_TOOLBOX_INITED=yes
	fi
fi

if [[ -e ~/.bash_environment.sh ]]; then
	source ~/.bash_environment.sh
fi

if [[ $TERM_PROGRAM == "vscode" ]]; then
	PROMPT_COMMAND="_run-prompt-commands"
	if ! [[ "$VSCODE_SHELL_INTEGRATION_SHELL_SCRIPT" ]]; then
		if command -v code-insiders &>/dev/null; then
			VSCODE_SHELL_INTEGRATION_SHELL_SCRIPT=$(code-insiders --locate-shell-integration-path bash 2>/dev/null)
		elif command -v code &>/dev/null; then
			VSCODE_SHELL_INTEGRATION_SHELL_SCRIPT=$(code --locate-shell-integration-path bash 2>/dev/null)
		fi
	fi

	if [[ -e $VSCODE_SHELL_INTEGRATION_SHELL_SCRIPT ]]; then
		# shellcheck source=/dev/null
		source "$VSCODE_SHELL_INTEGRATION_SHELL_SCRIPT"
		export VSCODE_SHELL_INTEGRATION_SHELL_SCRIPT
	else
		unset VSCODE_SHELL_INTEGRATION_SHELL_SCRIPT
	fi
fi

case "$-" in
*i*)
	# This shell is interactive
	;;
*)
	# This shell is not interactive
	return
esac


# export CLIENT_USERNAME="${USER_DISPLAYNAME:-${USERNAME}}"
# unset USERNAME
