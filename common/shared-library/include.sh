
_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${_DIR}/functions/basic.sh"
source "${_DIR}/functions/append-file.sh"

source "${_DIR}/functions/list.sh"
source "${_DIR}/functions/path-var.sh"

source "${_DIR}/functions/command.sh"

if [[ -e "/bin/cygpath.exe" ]]; then
	source "${_DIR}/detect-root/root-user.cygwin.sh"
else
	source "${_DIR}/detect-root/root-user.linux.sh"
fi

unset _DIR
register_exit_handle
