#!/bin/bash

set -Eeuo pipefail
shopt -s lastpipe

function callstack() {
	local -i SKIP=${1-1}
	local -i i
	for i in $(seq $SKIP $((${#FUNCNAME[@]} - 1))); do
		if [[ "${BASH_SOURCE[$((i + 1))]+found}" = "found" ]]; then
			echo "  $i: ${BASH_SOURCE[$((i + 1))]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}()"
		else
			echo "  $i: ${FUNCNAME[$i]}()"
		fi
	done
}
function _exit_handle() {
	RET=$?
	echo -ne "\e[0m"
	if [[ "$RET" -ne 0 ]]; then
		callstack 1
	fi
	exit $RET
}
trap _exit_handle EXIT

echo "starting installer...."

function die() {
	echo "" >&2
	echo -e "\e[38;5;9m$@\e[0m" >&2
	exit 1
}
function pad() {
	local i
	for ((i = 0; i < $1; i++)); do echo -n '  '; done
}

cd $(dirname ${BASH_SOURCE}) \
	|| die "internal error: can't get script folder"

export INSTALL_SCRIPT_ROOT=$(pwd)
export _INSTALLING_=$(pwd)
export GEN_BIN_PATH="${INSTALL_SCRIPT_ROOT}/.bin"
mkdir -p "${GEN_BIN_PATH}"
echo -e "installing scripts into \e[38;5;14m${INSTALL_SCRIPT_ROOT}\e[0m."

if [[ -e /etc/profile.d/linux-toolbox.sh ]]; then
	rm -f /etc/profile.d/linux-toolbox.sh
fi

TARGET=/etc/profile.d/01-linux-toolbox.sh
function emit() {
	echo "$@" >> "${TARGET}"
}
function emit_stdin() {
	cat >> "${TARGET}"
}
function emit_file() {
	cat "${_INSTALLING_}/$1" >> "${TARGET}"
}
function emit_source() {
	local CMD=$1
	shift

	echo -n "source ${VAR_HERE}/$CMD.sh" >> "${TARGET}"
	if [[ $# -eq 0 ]]; then
		echo -n ' ""' >> "${TARGET}"
	else
		for i in "$@"; do
			echo -n " '$i'" >> "${TARGET}"
		done
	fi

	echo "" >> "${TARGET}"
}
function emit_alias_sudo() { # command line ...
	emit "alias $1='\${SUDO}$@'"
}
function emit_alias_sudo2() { # command line ...
	local NAME=$1
	shift
	emit "alias $NAME='\${SUDO}$@'"
}
function copy_bin_with_env() {
	local ENV="$1"
	local SRC="$2"
	local DST="${3-$(basename "$SRC")}"
	local F="${_INSTALLING_}/$SRC"
	local T="${GEN_BIN_PATH}/$DST"
	rm -f "$T"
	{
		head -n 1 "$F"
		echo
		echo "$ENV"
		echo
		tail -n +2 "$F"
	} > "$T"
	chmod a+x "$T"
}
function copy_bin() {
	local SRC="$1"
	local DST="${2-$(basename "$SRC")}"
	local F="${_INSTALLING_}/$SRC"
	local T="${GEN_BIN_PATH}/$DST"
	if [[ -e "$T" ]] && [[ "$(readlink "$T")" = "$F" ]]; then
		return
	fi
	rm -f "$T"
	# echo ln -s "${F}" "$T"
	ln -s "${F}" "$T"
	chmod a+x "$F"
}
function copy_libexec() {
	local F="${_INSTALLING_}/$1"
	local TN="${2-$(basename "${F}")}"
	local T="/usr/local/libexec/$TN"
	cat "$F" > "$T"
	chmod a+x "$T"
	echo "$T"
}
function emit_relpath() {
	emit "path-var add \"${1}\""
}
function emit_path() {
	local PA="${_INSTALLING_}/$1"
	if [[ ! -e "$PA" ]]; then
		die "required folder not exists: ${PA}"
	fi

	chmod a+rx "$PA"

	local P="\$MY_SCRIPT_ROOT/$1"
	emit "path-var prepend \"${P}\""
}
function install_script() {
	local FOLDER="${1}"

	local PWD=$(pwd)
	echo -e "$(pad ${_INSTALL_LEVEL_-0})installing \e[38;5;11m.${PWD/"$INSTALL_SCRIPT_ROOT"/}/${FOLDER}/${2-install}.sh\e[0m ..."

	pushd "${FOLDER}" > /dev/null \
		|| die "can't run install script: $(pwd)/${FOLDER}"
	local _INSTALLING_=$(pwd) HERE=$(pwd)
	local VAR_HERE="\$MY_SCRIPT_ROOT${HERE/"$INSTALL_SCRIPT_ROOT"/}"

	# echo -e "\e[2mHERE=$HERE\e[0m"
	# echo -e "\e[2mVAR_HERE=$VAR_HERE\e[0m"

	local -i _INSTALL_LEVEL_="${_INSTALL_LEVEL_+$_INSTALL_LEVEL_} + 1"

	source "${_INSTALLING_}/${2-install}.sh"

	_INSTALL_LEVEL_="${_INSTALL_LEVEL_} - 1"

	echo -ne "$(pad ${_INSTALL_LEVEL_})${FOLDER}"
	[[ "${2+found}" = found ]] && echo -n " -> $2"
	echo -e " - \e[38;5;10mOK!\e[0m"

	popd > /dev/null
	_INSTALLING_=$(pwd) HERE=$(pwd)
	VAR_HERE="\$MY_SCRIPT_ROOT${HERE/"$INSTALL_SCRIPT_ROOT"/}"
}

### start
echo "create ${TARGET}"
[ -e "${TARGET}" ] && rm ${TARGET} || true

echo ": common tools..."
install_script common

echo ": system-spec tools..."
install_script system

echo ": quick-alias..."
install_script quick-alias

echo ": bash source..."
install_script bash_source

echo ": applications..."
for FILE in "${INSTALL_SCRIPT_ROOT}/applications/"*.sh; do
	install_script applications $(basename "$FILE" .sh)
done

echo ": user apps..."
install_script user

echo "write bashrc"
R=${RANDOM}
grep -v "LINUX_TOOLBOX_INITED" ~/.bashrc > /tmp/${R} 2> /dev/null
echo "# LINUX_TOOLBOX_INITED" >> /tmp/${R}
echo '[ -z "${LINUX_TOOLBOX_INITED}" -a "${-#*i}" = "$-" ] && source '"${TARGET}" >> /tmp/${R}
cat /tmp/${R} > ~/.bashrc
unlink /tmp/${R}
### end

echo -n "complete, try start it - "

source "${TARGET}" \
	|| {
		unlink "${TARGET}"
		die "can't start scripts, install failed."
	}

echo "ok."
