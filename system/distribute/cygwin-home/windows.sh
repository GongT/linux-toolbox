OIFS="$IFS"
IFS=:

for P in $PATH ; do
	if [[ "${P:0:10}" == "/cygdrive/" ]]; then
		list add WINDOWS_PATH "${P}"
	else
		list add LINUX_PATH "${P}"
	fi
done

export IFS="$OIFS"
unset OIFS

export WINDOWS_PATH
export LINUX_PATH
export PATH="$LINUX_PATH"

function run-windows() {
	PATH="$WINDOWS_PATH" "$@"
}

function run-cygpath() {
	local PATH="$WINDOWS_PATH"
	local PROGRAM=$1
	shift
	if [ $# -eq 0 ]; then
		"$PROGRAM"
	else
		local ARGS=()
		for var in "$@" ; do
			ARGS+=( "$( cygpath -m "$(realpath "$var")" )" )
		done
		"$PROGRAM" "${ARGS[@]}"
	fi
}
