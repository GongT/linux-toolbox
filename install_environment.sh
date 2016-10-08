#!/bin/bash

set -e

echo "starting installer...."

function die {
	echo "" >&2
	echo "$@" >&2
	exit 1
}

cd `dirname ${BASH_SOURCE}` || \
	die "internal error: can't get script folder"

[ -z "${1}" -o "$(pwd)" == "${1}" ] || \
	die -e "internal error: safe folder not equal\n\tactual: $(pwd)\n\texpect: ${1}"

export INSTALL_SCRIPT_ROOT=$(pwd)
export _INSTALLING_=`pwd`
echo -e "installing scripts into \e[38;5;14m${INSTALL_SCRIPT_ROOT}\e[0m."

TARGET=/etc/profile.d/linux-toolbox.sh
function emit {
	echo "$@" >> "${TARGET}"
}
function emit_stdin {
	cat >> "${TARGET}"
}
function emit_file {
	cat "${_INSTALLING_}/$@" | grep -vE '^#!' >> "${TARGET}"
}
function emit_source {
	echo "source '${_INSTALLING_}/$@'" >> "${TARGET}"
}
function emit_alias_sudo { # command line ...
	emit "alias $1=\${SUDO}'$@'"
}
function emit_path {
	local FOLDER="$@"
	local WORKING="${_INSTALLING_-${INSTALL_SCRIPT_ROOT}/}"
	local RET="${WORKING}/${FOLDER}"
	
	if [ ! -e "${RET}" ]; then
		die "required folder not exists: ${RET}"
	fi
	
	chmod a+x "${RET}"
	echo -n 'PATH="$PATH:' >> "${TARGET}"
	echo -n "${RET}" >> "${TARGET}"
	echo '"' >> "${TARGET}"
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
emit_source applications/_

emit "export PATH"
### end

echo "complete, try start it."

source "${TARGET}" || \
	{ unlink "${TARGET}" ; die "can't start scripts, install failed."; }


echo -en "PATH:\n    "
echo "$PATH" | sed 's/:/\n    /g'

echo "startup ok."
