# 命令行参数处理库
# 提供命令行参数解析功能，包括标志、键值对和位置参数的处理
# 其中键值对的形式为 --key=value，不支持 --key value 的形式
# 单线、双线都行，但不支持合并短选项 (如 -abc)

if declare -f arguments_init >/dev/null 2>&1; then
	# duplicate "source" protection
	return
fi

# shellcheck source=./output.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/output.sh"

declare -a _ARG_TOKENS=()
declare -a _ARG_USED_KEYS=()

declare -a ARGUMENTS_POSITIONAL=() # 外部可见，存储位置参数
declare -a ARGUMENTS_FLAGS=()      # 外部可见，存储标志参数 (--key)
declare -A ARGUMENTS_VALUES=()     # 外部可见，存储键值对参数 (--xxx -> yyy)

arguments_init() {
	if [[ ${#_ARG_TOKENS[@]} -gt 0 ]]; then
		die "arguments_init has already been called"
	fi
	_ARG_TOKENS=("$@")
	for token in "${_ARG_TOKENS[@]}"; do
		case "$token" in
		-*=*)
			key="${token%%=*}"
			value="${token#*=}"
			ARGUMENTS_VALUES["$key"]="$value"
			;;
		-*)
			ARGUMENTS_FLAGS+=("$token")
			;;
		*)
			ARGUMENTS_POSITIONAL+=("$token")
			;;
		esac
	done
}

_push_used() {
	if ! [[ " ${_ARG_USED_KEYS[*]} " =~ " $1 " ]]; then
		_ARG_USED_KEYS+=("$1")
	fi
}

arguments_read_flag() {
	local flag="$1"
	_push_used "$flag"
	for f in "${ARGUMENTS_FLAGS[@]}"; do
		if [[ $f == "$flag" ]]; then
			return 0
		fi
	done
	return 1
}

_set_variable() {
	local SRC
	SRC="$(printf '%s=%q' "$1" "$2")"
	# debug ":: $SRC"
	eval "$SRC"
}

arguments_optional_value() {
	local receiver=$1
	local key="$2"
	local default_value="${3}"
	_push_used "$key"

	if [[ ${ARGUMENTS_VALUES["$key"]+found} == found ]]; then
		_set_variable "${receiver}" "${ARGUMENTS_VALUES[$key]}"
	else
		_set_variable "${receiver}" "$default_value"
	fi
}

arguments_required_value() {
	local receiver=$1
	local key="$2"
	_push_used "$key"

	if [[ -n ${ARGUMENTS_VALUES[$key]+_} ]]; then
		_set_variable "${receiver}" "${ARGUMENTS_VALUES[$key]}"
	else
		usage "Required argument '$key' is missing"
	fi
}

arguments_finalize() {
	# 检查是否有未使用的参数
	local all_keys=("${!ARGUMENTS_VALUES[@]}" "${ARGUMENTS_FLAGS[@]}")
	for key in "${all_keys[@]}"; do
		if ! [[ " ${_ARG_USED_KEYS[*]} " == " $key " ]]; then
			debug "used keys: ${_ARG_USED_KEYS[*]}"
			usage "Unused argument detected: $key"
		fi
	done
}

# 从位置参数列表中移除第一个位置参数
arguments_shift_positional() {
	local receiver="${1-}"
	if [[ ${#ARGUMENTS_POSITIONAL[@]} -eq 0 ]]; then
		usage "Missing positional arguments"
	fi

	if [[ -n ${receiver} ]]; then
		_set_variable "$receiver" "${ARGUMENTS_POSITIONAL[0]}"
	fi
	ARGUMENTS_POSITIONAL=("${ARGUMENTS_POSITIONAL[@]:1}")
}

arguments_each_positional() {
	local callback="$1"
	local arg
	for arg in "${ARGUMENTS_POSITIONAL[@]}"; do
		"$callback" "$arg"
	done
}
