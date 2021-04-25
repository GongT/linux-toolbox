#!/bin/bash

CONTENT="$*"
COLOR=""

if [[ $CONTENT == '\e['*'m'* ]]; then
	COLOR="${CONTENT%%m*}m"
	CONTENT="${CONTENT#*m}"
	# echo "use COLOR=$COLOR  CONTENT=$CONTENT"
fi

if [[ ${COLUMNS+found} != found ]]; then
	COLUMNS=$(stty size | awk '{print $2}')
fi

LINE_LENGTH=$(echo "$CONTENT" | wc -L)

LEFT_PAD=$(((COLUMNS - LINE_LENGTH) / 2))
RIGHT_PAD=$((COLUMNS - LINE_LENGTH - LEFT_PAD))
# echo "LINE_LENGTH=$LINE_LENGTH  LEFT_PAD=$LEFT_PAD  RIGHT_PAD=$RIGHT_PAD"

if [[ $COLOR ]]; then
	printf "$COLOR"
fi
if [ ${LEFT_PAD} -gt 0 ]; then
	printf "%${LEFT_PAD}s"
fi

echo -ne "${CONTENT}"

if [ ${RIGHT_PAD} -gt 0 ]; then
	printf "%${RIGHT_PAD}s"
fi

if [[ $COLOR ]]; then
	printf "\e[0m"
fi
