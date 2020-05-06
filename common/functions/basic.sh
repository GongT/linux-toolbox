function __FILE__() {
	echo "$(realpath "${BASH_SOURCE[0]}")"
}
function __DIR__() {
	echo "$(dirname $(realpath "${BASH_SOURCE[0]}"))"
}

function die() {
	echo "" >&2
	echo "$@" >&2
	exit 1
}
