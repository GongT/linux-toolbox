#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

MY_SCRIPT_ROOT="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "${MY_SCRIPT_ROOT}" || die "internal error: can't get script folder"
declare -xr MY_SCRIPT_ROOT
declare -x HERE="$MY_SCRIPT_ROOT"

source "./common/shared-library/include.sh"

function pad() {
	die "pad is removed, use indent/indent- instead"
}

if [[ " $* " != *' --user '* ]] && is_root; then
	declare -r INSTALL_TARGET_FILE=/etc/profile.d/51-linux-toolbox.sh
	MY_LIBEXEC=/usr/local/libexec/linux-toolbox
	declare -xr INSTALL_TYPE='system'
	error " 🐧🐧🐧🐧 linux-toolbox @ ${INSTALL_TYPE}"
else
	MY_LIBEXEC="$HOME/.local/lib/linux-toolbox"
	declare -r INSTALL_TARGET_FILE="${MY_LIBEXEC}/.BASHPROFILE"

	ENTRY_FILE="$HOME/.bashrc"
	my_call file-section "$ENTRY_FILE" "MY LINUX TOOLBOX" "source '$INSTALL_TARGET_FILE'"
	declare -xr INSTALL_TYPE='user'
	success " 🐧🐧🐧🐧 linux-toolbox @ ${INSTALL_TYPE}"
fi
export GEN_BIN_PATH="${MY_LIBEXEC}/bin"
export GEN_HELPERS_PATH="${MY_LIBEXEC}/helpers"

writeln " * installing scripts into \e[38;5;14m${MY_LIBEXEC}\e[0m"
writeln " * entrypoint is \e[38;5;14m${INSTALL_TARGET_FILE}\e[0m"
filecopy_prepare
writeln

__INDENT=''
function install_script() {
	local FOLDER="${1}" PWD HERE

	PWD=$(pwd)
	writeln "installing \e[38;5;11m.${PWD/"$MY_SCRIPT_ROOT"/}/${FOLDER}/${2-install}.sh\e[0m"
	indent

	pushd "${FOLDER}" >/dev/null ||
		die "can't run install script: $(pwd)/${FOLDER}"
	HERE=$(pwd)

	# echo -e "\e[2mHERE=$HERE\e[0m"
	# echo -e "\e[2mVAR_HERE=$VAR_HERE\e[0m"

	local SRC="${HERE}/${2-install}.sh"
	emit "### === script: ${SRC#"${MY_SCRIPT_ROOT}"/} ==="

	# shellcheck source=/dev/null
	source "${SRC}"

	ok "${FOLDER}" "$([[ ${2+found} == found ]] && echo "-> $2")"

	popd >/dev/null
	indent-
	HERE=$(pwd)
}

### start
if [[ -e ${INSTALL_TARGET_FILE} ]]; then
	unlink "${INSTALL_TARGET_FILE}"
fi

header "preparing"
if [[ ${USER_DISPLAYNAME+found} == found ]]; then
	: # is correct
elif command_exists git && git config --get user.name &>/dev/null; then
	USER_DISPLAYNAME=$(git config --get user.name || true)
fi

if [[ -z ${USER_DISPLAYNAME-} ]]; then
	read -r -p "输入你的显示名称 (Display Name): " USER_DISPLAYNAME
fi
export USER_DISPLAYNAME

if is_root; then
	if [[ -e "${MY_LIBEXEC}/user-mode" ]]; then
		SINGLEUSER_MODE=$(<"${MY_LIBEXEC}/user-mode")
	else
		while true; do
			read -r -p "当前为root用户，是否以单用户模式安装？(y/n): " RESP
			case $RESP in
			[Yy]*)
				SINGLEUSER_MODE=true
				break
				;;
			[Nn]*)
				SINGLEUSER_MODE=false
				break
				;;
			esac
		done
		printf "$SINGLEUSER_MODE" >"${MY_LIBEXEC}/user-mode"
	fi
	if [[ $SINGLEUSER_MODE != "false" ]]; then
		echo "will installed as single user mode"
	fi
else
	SINGLEUSER_MODE=false
fi
export SINGLEUSER_MODE
is_single_user_mode() {
	[[ $SINGLEUSER_MODE != "false" ]]
}

header "common tools"
install_script common

header "system-spec tools"
install_script system

header "quick-alias"
install_script quick-alias

header "interactive"
emit 'if [[ $- == *i* ]]; then'
__INDENT=$'\t' install_script interactive
emit 'fi'

header "bash source"
install_script bash_source

header "applications"
for FILE in "${MY_SCRIPT_ROOT}/applications/"*.sh; do
	install_script applications "$(basename "$FILE" .sh)"
done

header "user apps"
install_script user

emit_sudo_part

header "ssh rc file"
if [[ -e ~/.bashrc ]]; then
	sed -i "/LINUX_TOOLBOX_INITED/d" ~/.bashrc
fi
install_script rc

debug "removing comments"
sed -Ei "/^\s*#.*$/d" "$INSTALL_TARGET_FILE"

if command_exists shfmt; then
	debug "reformat it with shfmt"
	shfmt -s -ln=bash -bn -w "$INSTALL_TARGET_FILE"
else
	warning "shfmt not found, best to install it"
fi

write "try source it"

# shellcheck source=/dev/null
source "${INSTALL_TARGET_FILE}" ||
	{
		unlink "${INSTALL_TARGET_FILE}"
		die "can't start scripts, install failed."
	}

ok "install complete. start"
