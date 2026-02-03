function emit() {
	echo "${__INDENT}$*" >>"${INSTALL_TARGET_FILE}"
}
function emitf() {
	local FORMAT="${__INDENT}$1"
	shift

	# shellcheck disable=SC2059
	printf "$FORMAT" "$@" >>"${INSTALL_TARGET_FILE}"
}
function emit_stdin() {
	sed "s|^|${__INDENT}|g" >>"${INSTALL_TARGET_FILE}"
}
function emit_file() {
	local SRC="${HERE}/$1"
	emit "### === emit file: ${SRC#"${MY_SCRIPT_ROOT}"/} ==="
	cat "${SRC}" | grep_safe -v '^#!' |
		emit_stdin
	# emit "### === end emit file: ${SRC#"${MY_SCRIPT_ROOT}"/} ==="
}
function emit_source() {
	local CMD=$1
	shift

	echo -n "${__INDENT}source ${VAR_HERE}/$CMD.sh" >>"${INSTALL_TARGET_FILE}"
	if [[ $# -eq 0 ]]; then
		echo -n ' ""' >>"${INSTALL_TARGET_FILE}"
	else
		for i in "$@"; do
			echo -n " '$i'" >>"${INSTALL_TARGET_FILE}"
		done
	fi

	echo "" >>"${INSTALL_TARGET_FILE}"
}

function _format_argv() {
	for I; do
		printf '%q ' "$I"
	done
}

_SUDOLIST=()
_NOT_SUDOLIST=()
function emit_alias_sudo() { # command line ...
	_SUDOLIST+=("alias $1='sudo --preserve-env $@'")
}
function emit_alias_sudo2() { # command line ...
	local NAME=$1 ARGV
	shift
	ARGV=$(_format_argv "$@")
	_SUDOLIST+=("alias $NAME='sudo --preserve-env $ARGV'")
	_NOT_SUDOLIST+=("alias $NAME='$ARGV'")
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

function emit_sudo_part() {
	emit "if ! is_root ; then"
	__INDENT=$'\t'
	if [[ ${#_SUDOLIST[@]} -gt 0 ]]; then
		for L in "${_SUDOLIST[@]}"; do
			emit "	$L"
		done
	else
		emit '	:'
	fi
	emit "else"
	if [[ ${#_NOT_SUDOLIST[@]} -gt 0 ]]; then
		for L in "${_NOT_SUDOLIST[@]}"; do
			emit "	$L"
		done
	else
		emit "	:"
	fi
	__INDENT=''
	emit "fi"
}

function emit_source_alias() {
	local ALIAS=$1 FILE="$2" _OUT_FILE

	_OUT_FILE=$(copy_library "$FILE")
	emit "alias ${ALIAS}='source ${_OUT_FILE}'"
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
