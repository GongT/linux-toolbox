_DL=0
if [[ -e /etc/DIR_COLORS ]]; then
	eval "$(dircolors -b /etc/DIR_COLORS)"
	_DL=1
fi
if [[ -e ~/.dir_colors ]]; then
	eval "$(dircolors -b ~/.dir_colors)"
	_DL=1
fi

if [[ $_DL -eq 0 ]]; then
	eval "$(dircolors -b)"
fi

unset _DL
