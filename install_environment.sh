#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/common/shared-library/include.sh"

echo "starting installer...."

function pad() {
	local i
	for ((i = 0; i < $1; i++)); do echo -n '  '; done
}

cd $(dirname ${BASH_SOURCE}) ||
	die "internal error: can't get script folder"

export MY_SCRIPT_ROOT=$(pwd)
export _INSTALLING_=$(pwd)

if [[ -e /etc/profile.d/linux-toolbox.sh ]]; then
	rm -f /etc/profile.d/linux-toolbox.sh
fi
if [[ -e /etc/profile.d/01-linux-toolbox.sh ]]; then
	rm -f /etc/profile.d/01-linux-toolbox.sh
fi
if [[ -e /etc/profile.d/00-environment.sh ]]; then
	mv /etc/profile.d/00-environment.sh /etc/profile.d/50-environment.sh
fi

if touch /etc/profile.d/51-linux-toolbox.sh; then
	declare -r TARGET=/etc/profile.d/51-linux-toolbox.sh
	MY_LIBEXEC=/usr/local/libexec/linux-toolbox
	declare -xr SUDO=""
else
	MY_LIBEXEC="$HOME/.local/lib/linux-toolbox"
	declare -r TARGET="${MY_LIBEXEC}/.BASHPROFILE"

	ENTRY_FILE="$HOME/.bashrc"
	file-section "$ENTRY_FILE" "MY LINUX TOOLBOX" "source '$TARGET'"
	declare -xr SUDO="sudo"
fi

echo -e "installing scripts into \e[38;5;14m${MY_LIBEXEC}\e[0m."

export GEN_BIN_PATH="${MY_LIBEXEC}/bin"
export PATH+=":${GEN_BIN_PATH}"

rm -rf "${GEN_BIN_PATH}"
mkdir -p "${GEN_BIN_PATH}"
cp -r "${MY_SCRIPT_ROOT}/bin/." "${GEN_BIN_PATH}"
find "${GEN_BIN_PATH}" -type f | xargs chmod a+x
path-var del "${GEN_BIN_PATH}" # prevent find_command return self

function emit() {
	echo "${__INDENT}$*" >>"${TARGET}"
}
function emitf() {
	local FORMAT="${__INDENT}$1"
	shift
	printf "$FORMAT" "$@" >>"${TARGET}"
}
function emit_stdin() {
	sed "s|^|${__INDENT}|g" >>"${TARGET}"
}
function emit_file() {
	local SRC="${_INSTALLING_}/$1"
	emit "### === emit file: ${SRC#${MY_SCRIPT_ROOT}/} ==="
	cat "${SRC}" | grep_safe -v '^#!' |
		emit_stdin
	# emit "### === end emit file: ${SRC#${MY_SCRIPT_ROOT}/} ==="
}
function emit_source() {
	local CMD=$1
	shift

	echo -n "${__INDENT}source ${VAR_HERE}/$CMD.sh" >>"${TARGET}"
	if [[ $# -eq 0 ]]; then
		echo -n ' ""' >>"${TARGET}"
	else
		for i in "$@"; do
			echo -n " '$i'" >>"${TARGET}"
		done
	fi

	echo "" >>"${TARGET}"
}
SUDOLIST=()
NOT_SUDOLIST=()
function emit_alias_sudo() { # command line ...
	SUDOLIST+=("alias $1='sudo --preserve-env $@'")
}
function emit_alias_sudo2() { # command line ...
	local NAME=$1 ARGV
	shift
	ARGV=$(_format_argv "$@")
	SUDOLIST+=("alias $NAME='sudo --preserve-env $ARGV'")
	NOT_SUDOLIST+=("alias $NAME='$ARGV'")
}
function emit_alias() {
	if [[ $1 == '--sudo' ]]; then
		shift
		emit_alias_sudo2 "$@"
		return
	fi

	local NAME=$1 ARGV
	shift

	ARGV=$(_format_argv "$@")
	emit "alias $NAME='$ARGV'"
}
function emit_source_alias() {
	local ALIAS=$1 FILE="$2" _OUT_FILE

	_OUT_FILE=$(copy_library "$FILE")
	emit "alias ${ALIAS}='source ${_OUT_FILE}'"
}
function _format_argv() {
	for I; do
		printf '%q ' "$I"
	done
}
function warp_bin_with_env() {
	local DST="${GEN_BIN_PATH}/$1" SRC="${_INSTALLING_}/$2"
	shift
	shift

	local ENV

	rm -f "$DST"
	{
		head -n 1 "$SRC"
		for ENV; do
			printf 'export "%q"\n' "$ENV"
		done
		tail -n +2 "$SRC"
	} >"$DST"
	chmod a+x "$DST"
}
function copy_bin() {
	local SRC="${_INSTALLING_}/$1"
	local DST="${GEN_BIN_PATH}/${2-$(basename "$SRC")}"
	if [[ -e ${DST} ]] && [[ "$(readlink "${DST}")" == "${SRC}" ]]; then
		return
	fi
	local DIR=$(dirname "${DST}")

	rm -f "$DST"
	cp "${SRC}" "$DST"
	chmod a+x "$DST"
}
function copy_library() {
	local F="${_INSTALLING_}/$1"
	local TN="${2-$(basename "${F}")}"
	local T="$MY_LIBEXEC/helpers/$TN"
	mkdir -p "$(dirname "$T")"
	cp "$F" "$T"
	echo "$T"
}
function emit_path() {
	local PA="$1"
	if [[ ${PA} != /* ]] || [[ ! -d $PA ]]; then
		die "required folder not exists: ${PA}"
	fi

	chmod a+rx "$PA"

	emitf 'path-var prepend %q\n' "${PA}"
	path-var prepend "${PA}"
}

__INDENT=''
function install_script() {
	local FOLDER="${1}"

	local PWD=$(pwd)
	echo -e "$(pad ${_INSTALL_LEVEL_-0})installing \e[38;5;11m.${PWD/"$MY_SCRIPT_ROOT"/}/${FOLDER}/${2-install}.sh\e[0m ..."

	pushd "${FOLDER}" >/dev/null ||
		die "can't run install script: $(pwd)/${FOLDER}"
	local _INSTALLING_=$(pwd) HERE=$(pwd)

	# echo -e "\e[2mHERE=$HERE\e[0m"
	# echo -e "\e[2mVAR_HERE=$VAR_HERE\e[0m"

	local -i _INSTALL_LEVEL_="${_INSTALL_LEVEL_+$_INSTALL_LEVEL_} + 1"

	local SRC="${_INSTALLING_}/${2-install}.sh"
	emit "### === script: ${SRC#${MY_SCRIPT_ROOT}/} ==="
	source "$SRC"

	_INSTALL_LEVEL_="${_INSTALL_LEVEL_} - 1"

	echo -ne "$(pad ${_INSTALL_LEVEL_})${FOLDER}"
	[[ ${2+found} == found ]] && echo -n " -> $2"
	echo -e " - \e[38;5;10mOK!\e[0m"

	popd >/dev/null
	_INSTALLING_=$(pwd) HERE=$(pwd)
}

### start
echo "create ${TARGET}"
[ -e "${TARGET}" ] && rm ${TARGET} || true

_debug_show_section() {
	echo -e "\n\e[38;5;14m: $*\e[0m" >&2
}

_debug_show_section "common tools..."
install_script common

_debug_show_section "system-spec tools..."
install_script system

_debug_show_section "quick-alias..."
install_script quick-alias

_debug_show_section "interactive..."
emit 'if [[ $- == *i* ]]; then'
install_script interactive
emit 'fi'

_debug_show_section "bash source..."
install_script bash_source

_debug_show_section "applications..."
for FILE in "${MY_SCRIPT_ROOT}/applications/"*.sh; do
	install_script applications $(basename "$FILE" .sh)
done

_debug_show_section "user apps..."
install_script user

emit "if ! is_root ; then"
if [[ ${#SUDOLIST[@]} -gt 0 ]]; then
	for L in "${SUDOLIST[@]}"; do
		emit "	$L"
	done
else
	emit '	:'
fi
emit "else"
if [[ ${#NOT_SUDOLIST[@]} -gt 0 ]]; then
	for L in "${NOT_SUDOLIST[@]}"; do
		emit "	$L"
	done
else
	emit "	:"
fi
emit "fi"

_debug_show_section "ssh rc file..."
if [[ -e ~/.bashrc ]]; then
	sed -i "/LINUX_TOOLBOX_INITED/d" ~/.bashrc
fi
install_script rc

echo "removing comments..."
sed -Ei "/^\s*#.*$/d" "$TARGET"

if command_exists shfmt; then
	echo "reformat it with shfmt..."
	shfmt -s -ln=bash -bn -w "$TARGET" "$TARGET"
fi


echo -n "complete, try start it - "
# shellcheck source=01-linux-toolbox.sh
source "${TARGET}" ||
	{
		unlink "${TARGET}"
		die "can't start scripts, install failed."
	}

echo "ok."
