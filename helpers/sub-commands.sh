# 子命令支持，引用此文件前应有如下准备:
#   - COMMAND_PRIMARY_TITLE="xxxxx" # 通常可设为 $0 用于显示 Usage: <COMMAND_PRIMARY_TITLE>
# 每个子命令例如 "build", "clean" 必须定义对应的函数:
#   - "execute_build": 执行 "build" 子命令，参数为除了子命令本身之外的所有参数
#   - "usage_build": 应输出 "build" 子命令的用法到stderr（到stdout也可以）
# 并注册过: `execute_describe_subcommand build "运行构建命令"`
# 其他子命令依此类推

if declare -f execute_subcommands >/dev/null 2>&1; then
	# duplicate "source" protection
	return
fi

# shellcheck source=./arguments.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/arguments.sh"

ACTION=""
declare -A _SUBCOMMAND_REGISTRY=()

function execute_describe_subcommand() {
	local subcommand="$1"
	local description="$2"
	_SUBCOMMAND_REGISTRY["$subcommand"]="$description"
}

# 执行主函数，应以 execute_subcommands "$@" 的形式调用
function execute_subcommands() {
	arguments_init "$@"
	local possible_action execute_function

	if [[ ${#ARGUMENTS_POSITIONAL[@]} -eq 0 ]]; then
		usage "No subcommand provided"
	fi

	arguments_shift_positional possible_action
	execute_function="execute_${possible_action}"
	if declare -f "$execute_function" >/dev/null; then
		ACTION="$possible_action"
		"$execute_function" "$@"
	else
		usage "Unknown subcommand: $possible_action"
	fi
}

# 显示主命令的用法信息，通常会调用各个子命令的 usage_<subcommand> 函数
function usage() {
	local code subcommand="$ACTION"
	if [[ $1 =~ ^[0-9]+$ ]]; then
		code="$1"
		shift
	else
		code=1
	fi
	local message="$*"
	# debug "call usage() with: code=$code, subcommand=$subcommand, message=$message"

	if [[ -n $message ]]; then
		warning "$message"
	fi
	writeln ""

	if [[ -z $subcommand ]]; then
		writeln "Usage: $COMMAND_PRIMARY_TITLE <subcommand> [options]"
		writeln

		writeln "Available subcommands:"
		for subcommand in "${!_SUBCOMMAND_REGISTRY[@]}"; do
			description="${_SUBCOMMAND_REGISTRY[$subcommand]}"
			printf "  %-15s %s\n" "$subcommand" "$description"
		done
	else
		writeln "Usage: $COMMAND_PRIMARY_TITLE $subcommand [options]"
		writeln ""
		local usage_function="usage_$subcommand"
		if declare -f "$usage_function" >/dev/null; then
			indent
			"$usage_function" 1>&2
			indent-
		else
			die "No usage information for subcommand: $subcommand"
		fi
	fi

	writeln ""
	if [[ -n $message ]]; then
		error "$message"
	fi

	# writeln ""
	# debug "Exiting with code $code"
	exit "$code"
}
