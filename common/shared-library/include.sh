
_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${_DIR}/functions/basic.sh"
source "${_DIR}/functions/append-file.sh"

source "${_DIR}/functions/list.sh"
source "${_DIR}/functions/path-var.sh"

source "${_DIR}/functions/command.sh"
unset _DIR
register_exit_handle
