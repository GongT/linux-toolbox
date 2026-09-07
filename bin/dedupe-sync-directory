#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

USAGE_STR="删除文件夹A中同时存在于文件夹B的文件

使用方法: $0 [-n] <dir_a> <dir_b>
  -n       仅显示将要删除的文件（模拟运行）
  dir_a    要删除文件的目录
  dir_b    用于去重的目录
"
# 使用方法: ./dedup.sh [-n] <dir_a> <dir_b>
#   -n  仅显示将要删除的文件（模拟运行）

DRY_RUN=false
while getopts "n" opt; do
	case $opt in
	n) DRY_RUN=true ;;
	*)
		echo "$USAGE_STR" >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

DIR_A="${1:?$USAGE_STR}"
DIR_B="${2:?$USAGE_STR}"

# 解析为绝对路径
DIR_A="$(realpath -e "$DIR_A")"
DIR_B="$(realpath -e "$DIR_B")"

declare -i count=0

f1=/tmp/f1.txt
cd "$DIR_A" && find . -type f | sed 's|^\./||' | sort >"$f1"

f2=/tmp/f2.txt
cd "$DIR_B" && find . -type f | sed 's|^\./||' | sort >"$f2"

while IFS= read -r rel_path; do
	target="$DIR_A/$rel_path"
	if [[ ! -e "$target" ]] && [[ ! -L "$target" ]]; then
		continue
	fi

	if $DRY_RUN; then
		if [[ $count -lt 100 ]]; then
			echo "[dry-run] 将要删除: $target"
		elif [[ $count -eq 100 ]]; then
			echo "[dry-run] 隐藏更多文件..."
		fi
	else
		rm -f "$target"
		printf "\e[0K已删除: $target\r"
	fi
	count+=1
done < <(comm -12 "$f1" "$f2")

if ! $DRY_RUN; then
	printf "\e[0K"
fi

echo "--------------------------------"
if $DRY_RUN; then
	echo "将要删除的文件总数: $count"
else
	echo "已删除的文件总数: $count"

	find "$DIR_A" -type d -empty -delete
fi
