if [ -n "$DISPLAY" ] && read -r proto cookie; then
	if [ "$(echo "$DISPLAY" | cut -c1-10)" = 'localhost:' ]; then
		# X11UseLocalhost=yes
		echo add "unix:$(echo "$DISPLAY" | cut -c11-)" "$proto" "$cookie"
	else
		# X11UseLocalhost=no
		echo add "$DISPLAY" "$proto" "$cookie"
	fi | xauth -q -
fi

if [ -n "$BASH_VERSION" ]; then
	if ! [[ "${LINUX_TOOLBOX_INITED}" ]] && [[ "${-#*i}" = "$-" ]]; then
		source "__LINUX_TOOLBOX_INIT__"
	fi
fi

