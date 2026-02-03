INSTALLED_BINS=()
function copy_bin() {
	local SOURCE_FILE="$1" TARGET_BASE TARGET_FILE CONTENT
	shift

	if [[ $SOURCE_FILE != /* ]]; then
		SOURCE_FILE="${HERE}/${SOURCE_FILE}"
	fi

	if [[ $# -eq 0 ]]; then
		TARGET_BASE=$(basename "$SOURCE_FILE" .sh)
	else
		TARGET_BASE="$1"
		shift
	fi
	TARGET_FILE="${GEN_BIN_PATH}/$TARGET_BASE"

	CONTENT=$(
		head -n 1 "$SOURCE_FILE"
		for ENV; do
			printf 'export "%q"\n' "$ENV"
		done
		tail -n +2 "$SOURCE_FILE"
	)

	write_file_if_changed "$TARGET_FILE" "$CONTENT"

	debug "create binary file: $TARGET_BASE - ${LAST_FILE_CHANGED}"
	INSTALLED_BINS+=("$TARGET_FILE")
}

function copy_library() {
	local SOURCE_FILE="$1" TARGET_BASE TARGET_FILE CONTENT
	shift

	if [[ $SOURCE_FILE != /* ]]; then
		SOURCE_FILE="${HERE}/${SOURCE_FILE}"
	fi

	CONTENT=$(
		head -n 1 "$SOURCE_FILE"
		for ENV; do
			printf 'export "%q"\n' "$ENV"
		done
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
	for FILE in "${FILES[@]}"; do
		if ! array_contains "$FILE" "${INSTALLED_BINS[@]}"; then
			debug " - $FILE"
			"${_SUDO[@]}" unlink "$FILE"
		fi
	done
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
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return "$in"
}
