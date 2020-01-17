#!/bin/bash

set -e

echo "starting installer...."

function die {
	echo "" >&2
	echo -e "\e[38;5;9m$@\e[0m" >&2
	exit 1
}

cd `dirname ${BASH_SOURCE}` || \
	die "internal error: can't get script folder"

[ -z "${1}" -o "$(pwd)" = "${1}" ] || \
	die -e "internal error: safe folder not equal\n\tactual: $(pwd)\n\texpect: ${1}"

export INSTALL_SCRIPT_ROOT=$(pwd)
export _INSTALLING_=`pwd`
export GEN_BIN_PATH="${INSTALL_SCRIPT_ROOT}/.bin"
mkdir -p "${GEN_BIN_PATH}"
echo -e "installing scripts into \e[38;5;14m${INSTALL_SCRIPT_ROOT}\e[0m."

if [[ -e /etc/profile.d/linux-toolbox.sh ]]; then
	rm -f /etc/profile.d/linux-toolbox.sh 
fi

TARGET=/etc/profile.d/00-linux-toolbox.sh
function emit {
	echo "$@" >> "${TARGET}"
}
function emit_stdin {
	cat >> "${TARGET}"
}
function emit_file {
	cat "${_INSTALLING_}/$1" | grep -vE '^#!' >> "${TARGET}"
}
function emit_source {
	echo "source ${_INSTALLING_}/$*" >> "${TARGET}"
}
function emit_alias_sudo { # command line ...
	emit "alias $1='\${SUDO}$@'"
}
function copy_bin () {
	chmod a+x "${_INSTALLING_}/$@"
	for i in "${_INSTALLING_}/$@"
	do
		local T="${GEN_BIN_PATH}/`basename "${i}"`"
		if [[ -e "$T" ]] || [[ -L "$T" ]]; then
			unlink "$T"
		fi
		echo ln -s "${i}" "$T"
		ln -s "${i}" "$T"
	done
}
function emit_path {
	local RET="${_INSTALLING_}/$1"

	if [ ! -e "${RET}" ]; then
		die "required folder not exists: ${RET}"
	fi

	chmod a+x "${RET}"

	emit "source ${INSTALL_SCRIPT_ROOT}/bash_source/path-var add \"${RET}\""
}
function install_script {
	local FOLDER="${1}"

	echo -ne "installing \e[38;5;11m${FOLDER}"
	[ -n "$2" ] && echo -n " -> $2"
	echo -e "\e[0m..."

	pushd "${FOLDER}" >/dev/null || \
	 	die "can't run install script: `pwd`/${FOLDER}"
	export _INSTALLING_=`pwd`

	source "${_INSTALLING_}/${2-install}.sh"

	echo -ne "${FOLDER}"
	[ -n "$2" ] && echo -n " -> $2"
	echo -e " - \e[38;5;10mOK!\e[0m"

	popd >/dev/null
	export _INSTALLING_=`pwd`
}

### start
echo "create ${TARGET}"
[ -e "${TARGET}" ] && rm ${TARGET} || true

echo ": common tools..."
install_script common

emit_path bin

echo ": system-spec tools..."
install_script system

echo ": quick-alias..."
install_script quick-alias

echo ": bash source..."
install_script bash_source

echo ": applications..."
install_script applications docker
install_script applications dnf
install_script applications node
install_script applications journald
emit "source ${INSTALL_SCRIPT_ROOT}/bash_source/path-var append './node_modules/.bin'"
emit "source ${INSTALL_SCRIPT_ROOT}/bash_source/path-var append './common/temp/node_modules/.bin'"
emit_path .bin

emit "export PATH"

echo "write bashrc"
R=${RANDOM}
grep -v "LINUX_TOOLBOX_INITED" ~/.bashrc >/tmp/${R} 2>/dev/null
echo "# LINUX_TOOLBOX_INITED" >> /tmp/${R}
echo '[ -z "${LINUX_TOOLBOX_INITED}" -a "${-#*i}" = "$-" ] && source '"${TARGET}" >> /tmp/${R}
cat /tmp/${R} > ~/.bashrc
unlink /tmp/${R}
### end

echo "complete, try start it."

LINUX_TOOLBOX_INITED=

source "${TARGET}" || \
	{ unlink "${TARGET}" ; die "can't start scripts, install failed."; }

echo -en "PATH:\n    "
echo "$PATH" | sed 's/:/\n    /g'

echo "startup ok."
