INSTALLED_BINS=()
function _env_process_bash() {
	for ENV; do
		printf 'export "%q"\n' "$ENV"
	done
}

function _env_process_python() {
	for ENV; do
		printf '%s=%q\n' "${ENV%%=*}" "${ENV#*=}"
	done
}

function _env_process_tk() {
	for ENV; do
		printf 'set env "%q" "%q"\n' "${ENV%%=*}" "${ENV#*=}"
	done
}

function _get_env_process() {
	case "$1" in
	*.sh)
		echo "_env_process_bash"
		;;
	*.py)
		echo "_env_process_python"
		;;
	*.expect)
		echo "_env_process_tk"
		;;
	*)
		echo "_env_process_noop"
		;;
	esac
}

function _env_process_noop() {
	if [[ $# -gt 0 ]]; then
		die "Can't process environment variables: unknown script type."
	fi
}

function copy_bin() {
	local SOURCE_FILE="$1" TARGET_BASE TARGET_FILE CONTENT env_process
	shift

	if [[ $SOURCE_FILE != /* ]]; then
		SOURCE_FILE="${HERE}/${SOURCE_FILE}"
	fi

	if [[ $# -eq 0 ]]; then
		if [[ $SOURCE_FILE == *.sh ]]; then
			TARGET_BASE=$(basename "$SOURCE_FILE" .sh)
		elif [[ $SOURCE_FILE == *.py ]]; then
			TARGET_BASE=$(basename "$SOURCE_FILE" .py)
		elif [[ $SOURCE_FILE == *.expect ]]; then
			TARGET_BASE=$(basename "$SOURCE_FILE" .expect)
		else
			TARGET_BASE=$(basename "$SOURCE_FILE")
		fi
	else
		TARGET_BASE="$1"
		shift
	fi
	TARGET_FILE="${GEN_BIN_PATH}/$TARGET_BASE"

	env_process="$(_get_env_process "$SOURCE_FILE")"
	CONTENT=$(
		head -n 1 "$SOURCE_FILE"
		"$env_process" "$@"
		tail -n +2 "$SOURCE_FILE"
	)

	write_file_if_changed "$TARGET_FILE" "$CONTENT"

	if [[ ${LAST_FILE_CHANGED-} -eq 0 ]]; then
		debug "binary file unchanged: $TARGET_BASE"
	else
		success "create binary file: $TARGET_BASE"
	fi
	INSTALLED_BINS+=("$TARGET_FILE")
}

function copy_library() {
	local SOURCE_FILE="$1" TARGET_BASE TARGET_FILE CONTENT env_process
	shift

	if [[ $SOURCE_FILE != /* ]]; then
		SOURCE_FILE="${HERE}/${SOURCE_FILE}"
	fi

	env_process="$(_get_env_process "$SOURCE_FILE")"
	CONTENT=$(
		head -n 1 "$SOURCE_FILE"
		"$env_process" "$@"
		tail -n +2 "$SOURCE_FILE"
	)

	TARGET_BASE="$(basename "${SOURCE_FILE}")"
	TARGET_FILE="${GEN_HELPERS_PATH}/$TARGET_BASE"

	write_file_if_changed "$TARGET_FILE" "$CONTENT"
	echo "$TARGET_FILE"

	debug "create library file: $TARGET_BASE"
}

function filecopy_prepare() {
	writeln " * binary folder \e[38;5;14m${GEN_BIN_PATH}\e[0m"
	writeln " * library folder \e[38;5;14m${GEN_HELPERS_PATH}\e[0m"

	mkdir -p "${GEN_BIN_PATH}"
	path-var del "${GEN_BIN_PATH}" # prevent find_command return self

	warning "install binary files..."
	indent
	local FILE FILES
	mapfile -t FILES < <(find "${MY_SCRIPT_ROOT}/bin" -type f)
	for FILE in "${FILES[@]}"; do
		copy_bin "${FILE}"
	done
	indent-

	atexit filecopy_post_install
}

function filecopy_post_install() {
	local FILE FILES
	mapfile -t FILES < <(find "${GEN_BIN_PATH}" -type f)

	warning "remove stale binary files..."
	indent
	local -i CNT=0
	for FILE in "${FILES[@]}"; do
		if ! array_contains "$FILE" "${INSTALLED_BINS[@]}"; then
			debug " - $FILE"
			"${_SUDO[@]}" unlink "$FILE"
			((CNT++))
		fi
	done
	debug "removed $CNT stale binary files"
	indent-

	debug "make binaries executable"
	find "${GEN_BIN_PATH}" -type f -print0 | xargs -0 chmod a+x
}

function my_call() {
	local PATH="${MY_SCRIPT_ROOT}/bin:${PATH}"
	"$@"
}

array_contains() {
	local seeking="$1"
	local in=1
	for element in "${@:2}"; do
		if [[ $element == "$seeking" ]]; then
			in=0
			break
		fi
	done
	return "$in"
}
