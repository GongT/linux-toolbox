#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

_SUDO=()
if [[ $UID -ne 0 ]]; then
	_SUDO+=(sudo)
fi

function _dnf() {
	printf "\e[2m$ %s %s\e[0m\n" "${_SUDO[*]} ${DNF}" "$*" >&2
	exec "${_SUDO[@]}" "${DNF}" "$@"
}

if [[ $* == *"--complete"* ]]; then
	exec "${_SUDO[@]}" "${DNF}" "$@"
fi

function parse_provide_file_arg() {
	function arg() {
		echo -ne ${ARG}
	}
	if arg | grep -q '/'; then # has path
		ARGS+=("$ARG")
		return
	fi
	if arg | grep -qE '\s'; then # has any empty - must not a well-known file
		ARGS+=("$ARG")
		return
	fi
	if arg | grep -qE '.so$'; then
		echo -e "use [\e[38;5;14m dnf search ${ARG%.so} \e[0m] instead."
		exit
	fi
	if arg | grep -qE '\.so[.\d]+$'; then
		ARGS+=("/usr/lib64/$ARG")
		return
	fi
	if arg | grep -iqE '\.h$'; then
		ARGS+=("/usr/include/*/$ARG")
		return
	fi
	if arg | grep -qE '[^/.]+$'; then
		for dir in /usr/bin /usr/sbin /usr/local/bin; do
			ARGS+=("${dir}/$ARG")
		done
		return
	fi
}

function die() {
	echo "$*" >&2
	exit 1
}

function is_fc_earlier() {
	local MAX="$1" PKG_NAME="$2"
	local -i i=0
	for ((i = 1; i < MAX; i++)); do
		if [[ $PKG_NAME == *".fc$i."* ]]; then
			return 0
		fi
	done
	return 1
}

function check_database() {
	local V="${1:-}"
	if ! grep -q 'ID=fedora' /etc/os-release; then
		die "无法在非 Fedora 系统上使用"
	fi
	local FC_VER
	FC_VER=$(grep -oP '(?<=VERSION_ID=)"?\K[0-9]+' /etc/os-release || true)
	if [[ -z $FC_VER ]]; then
		die "无法获取 Fedora 版本"
	fi
	if ! rpm -q "fedora-release-$FC_VER" &>/dev/null; then
		die "Fedora 版本 $FC_VER 的 release 包未安装"
	fi
	echo "Fedora 版本: $FC_VER"

	local PACKAGES_STR PACKAGES=()
	PACKAGES_STR=$(rpm -qa)
	echo " * 当前系统安装了 $(echo "$PACKAGES_STR" | wc -l) 个软件包"

	mapfile -t PACKAGES < <(echo "$PACKAGES_STR" | grep -v -F ".fc${FC_VER}.")

	local ERR_ARCH=() ERR_MISMATCH=()
	mapfile -t ERR_ARCH < <(rpm -qa | grep -v -F '.noarch' | grep -v -F '.x86_64' | grep -F '.')
	for pkg in "${PACKAGES[@]}"; do
		if is_fc_earlier "$FC_VER" "$pkg"; then
			ERR_MISMATCH+=("$pkg")
		fi
	done
	echo " * 架构异常: ${#ERR_ARCH[@]}"
	if [[ $V == '-v' ]]; then
		for pkg in "${ERR_ARCH[@]}"; do
			echo "   ! $pkg"
		done
	fi
	echo " * 版本不匹配: ${#ERR_MISMATCH[@]}"
	if [[ $V == '-v' ]]; then
		for pkg in "${ERR_MISMATCH[@]}"; do
			echo "   ! $pkg"
		done
	fi

	if [[ ${#ERR_ARCH[@]} -ne 0 || ${#ERR_MISMATCH[@]} -ne 0 ]]; then
		if [[ $V != '-v' ]]; then
			echo "使用 -v 查看详细信息"
		fi
		exit 1
	fi
}

case ${1:-''} in
i)
	shift
	_dnf install -y "$@"
	;;
s)
	shift
	if [ $# -eq 0 ]; then
		_dnf search
	else
		S="*"
		for i in "$@"; do
			S+="$i*"
		done
		e0=$(echo -ne '\e[0m')
		e9=$(echo -ne '\e[38;5;9m')
		e10=$(echo -ne '\e[38;5;10m')
		# DNF="unbuffer /usr/bin/dnf"
		_dnf list "$S" | grep -v '.i686' |
			sed "s#Available Packages#${e9}\0${e0}#g" |
			sed "s#Installed Packages#${e10}\0${e0}#g"
	fi
	;;
p)
	shift
	ARGS=()
	for ARG in "$@"; do
		parse_provide_file_arg
	done
	_dnf provides "${ARGS[@]}"
	;;
c)
	shift
	check_database "$@"
	;;
'--help' | '-h')
	shift
	;&
'')
	"${DNF}" --help "$@"
	if [[ $# -eq 0 ]]; then
		{
			echo ""
			echo "正在使用dnf包装脚本，额外支持命令:"
			echo "  i    安装软件包并添加-y"
			echo "  s    搜索软件包"
			echo "  p    查询可执行文件、库、头文件归属"
			echo "  c    检查包管理状态"
		} >&2
	fi
	exit 1
	;;
*)
	_dnf "$@"
	;;
esac
