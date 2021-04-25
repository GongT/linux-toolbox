#!/usr/bin/env bash

# https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit

set -Eeuo pipefail

if [[ ${COLUMNS+found} != found ]]; then
	declare -i COLUMNS
	COLUMNS=$(stty size | awk '{print $2}')
	if [[ $COLUMNS -le 0 ]]; then
		echo "failed get tty size, use 80" >&2
		COLUMNS=80
	fi
	if [[ $COLUMNS -le 30 ]]; then
		echo "Your terminal is too small"
	fi
fi
export COLUMNS
TITLE_STYLE='48;5;8;1'

function rgb8() {
	local R=$1 G=$2 B=$3
	echo -n $((R * 36 + G * 6 + B + 16))
}
function title() {
	echo
	center "\e[${TITLE_STYLE}m$*"
}

declare -i CURR_WIDTH=0
function newline_iif() {
	local -i ELEMENT_SIZE=$1
	local NEW_LINE="${2:-\n}" OTHERWISE="${3:-}"
	if newline_if "$ELEMENT_SIZE"; then
		echo -ne "\e[0m${NEW_LINE}"
		CURR_WIDTH=0
	else
		echo -ne "\e[0m${OTHERWISE}"
		return 1
	fi
}
function newline_if() {
	local -i ELEMENT_SIZE=$1
	CURR_WIDTH+=$ELEMENT_SIZE
	if [[ $((CURR_WIDTH + ELEMENT_SIZE)) -gt $COLUMNS ]]; then
		CURR_WIDTH=0
	else
		return 1
	fi
}
function newline_reset() {
	local NEW_LINE="${1:-\n}"
	CURR_WIDTH=0
	echo -ne "\e[0m$NEW_LINE"
}

title "属性序列"

PROP_ARR=(
	1 明亮
	1:2 阴影
	2 黯淡
	3 斜体
	5 闪烁
	6 快闪
	7 反相
	8 隐藏
	4 下划线
	4:2 双线
	4:3 波浪线
	4:4 短划线
	4:5 长划线
	9 中划线
	53 上划线
)

PROP_VALUE_CACHE=""
for ((i = 0; i < ${#PROP_ARR[@]}; i += 2)); do
	TYPE=${PROP_ARR[$((i + 1))]}
	VALUE=${PROP_ARR[$i]}
	LEN=$(echo "$TYPE" | wc -L)
	echo -en "$(printf "%$((9 - LEN))s")$TYPE"
	PROP_VALUE_CACHE+=$(printf "\e[${VALUE}m%9s\e[0m%s" "$VALUE")
	if newline_if 9; then
		echo -ne "\n$PROP_VALUE_CACHE\n"
		PROP_VALUE_CACHE=''
	else
		echo -ne ""
	fi
done
if [[ $PROP_VALUE_CACHE ]]; then
	newline_reset "\n$PROP_VALUE_CACHE\n\e[0m"
else
	newline_reset
fi

title "基础颜色序列"

BASE_COLOR="1111111010000000"
for I in $(seq 0 $((${#BASE_COLOR} - 1))); do
	if [[ ${BASE_COLOR:I:1} == 0 ]]; then
		printf '\e[38;5;0m'
	fi
	printf "\e[48;5;${I}m%4s \e[0m" "$I"
	if newline_if 5; then
		echo -e "\e[K"
	fi
done
newline_reset

title "256色矩阵"
declare -a MATRIX1=() MATRIX2=() MATRIX3=() MATRIX4=() MATRIX5=() MATRIX6=()
mapfile -t TABLE_SEQ < <(seq 0 5)
declare -r TABLE_SEQ
function generate_matrix() {
	local -i CURR=$2 LIGHT_C=$3 COL ROW
	local VAR_NAME=$1 STR

	for ROW in "${TABLE_SEQ[@]}"; do
		STR=''
		for COL in "${TABLE_SEQ[@]}"; do
			if [[ $((5 - COL)) -gt $ROW ]] || [[ "$ROW$LIGHT_C" == 01 ]]; then
				FG="0;1;"
			else
				FG="0;1;38;5;0;"
			fi
			STR+="\e[${FG}48;5;${CURR}m$(printf "%4s" "$CURR") "
			CURR=$((CURR + 1))
		done
		eval "${VAR_NAME}[$ROW]='$STR\e[0m'"
	done
}
function print_matrix() {
	local ROW INDEX
	for ROW in "${TABLE_SEQ[@]}"; do
		for INDEX in "$@"; do
			declare -n PTR="MATRIX$INDEX"
			echo -en "${PTR[$ROW]}   "
		done
		echo
	done
	echo
}

generate_matrix MATRIX1 16 1
generate_matrix MATRIX2 52 1
generate_matrix MATRIX3 88 1
generate_matrix MATRIX4 124 0
generate_matrix MATRIX5 160 0
generate_matrix MATRIX6 196 0

MATRIX_WIDTH=30
MATRIX_SPACE=3
if [[ $COLUMNS -gt $((MATRIX_WIDTH * 6 + MATRIX_SPACE * 5)) ]]; then
	print_matrix 1 2 3 4 5 6
elif [[ $COLUMNS -gt $((MATRIX_WIDTH * 3 + MATRIX_SPACE * 2)) ]]; then
	print_matrix 1 2 3
	print_matrix 4 5 6
elif [[ $COLUMNS -gt $((MATRIX_WIDTH * 2 + MATRIX_SPACE * 1)) ]]; then
	print_matrix 1 2
	print_matrix 3 4
	print_matrix 5 6
else
	for I in $(seq 1 6); do
		print_matrix "$I"
	done
fi

for I in $(seq 232 243); do
	printf "\e[48;5;${I}m%4s \e[0m" "$I"
	if newline_if 5; then
		echo -e "\e[K"
	fi
done
newline_reset
for I in $(seq 244 255); do
	printf "\e[38;5;0;48;5;${I}m%4s \e[0m" "$I"
	if newline_if 5; then
		echo -e "\e[K"
	fi
done
newline_reset

title "备注"
printf "前景色\t%s\n" '\e[38;??m\t背景色： \e[48;??m'
printf "8-bit\t%s\n" '\e[x8;5;{INDEX}m - 0-255'
printf "真彩色\t%s\n" '\e[x8;2;{RED};{GREEN};{BLUE}m - 0-255'

echo " * $(hyperlink 'ANSI scape code' 'https://en.wikipedia.org/wiki/ANSI_escape_code')"
echo " * $(hyperlink 'mintty Tips' 'https://github.com/mintty/mintty/wiki/Tips#text-attributes-and-rendering')"
echo " * $(hyperlink ' XTerm Control Sequences' 'https://invisible-island.net/xterm/ctlseqs/ctlseqs.html')"
