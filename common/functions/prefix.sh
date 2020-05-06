if [[ "${_INSTALL_LEVEL_+found}" != "found" ]]; then
	if [ "$0" != "-bash" ] && [ "$0" != "bash" ] && [ "$0" != "/bin/bash" ] && [ "$0" != "/usr/bin/bash" ]; then
		return
	fi
	case "$-" in
	*i*)
		# This shell is interactive
		;;
	*)
		# This shell is not interactive
		if [[ "$PROXY" ]] && [[ "$VSCODE_AGENT_FOLDER" ]]; then
			export http_proxy="$PROXY" https_proxy="$PROXY"
		fi
		return
		;;
	esac

	if [[ "${LINUX_TOOLBOX_INITED-no}" = "yes" ]]; then
		return
	else
		declare +rx LINUX_TOOLBOX_INITED=yes
	fi
fi

if [[ -e ~/.bash_environment.sh ]]; then
	source ~/.bash_environment.sh
fi
