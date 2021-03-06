#!/bin/bash

case "$0" in
*bash*)
	# is BASH, continue
	;;
*)
	return # not using BASH
	;;
esac

if [[ "${_INSTALL_LEVEL_+found}" != "found" ]]; then
	if [[ "${LINUX_TOOLBOX_INITED:-no}" = "yes" ]]; then
		return
	else
		declare -r LINUX_TOOLBOX_INITED=yes
	fi
fi

if [[ -e ~/.bash_environment.sh ]]; then
	source ~/.bash_environment.sh
fi
