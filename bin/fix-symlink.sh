#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

declare -r COMMAND_PRIMARY_TITLE="fix-symlink"

# shellcheck source=./../helpers/sub-commands.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../helpers/sub-commands.sh"

_MOUNTPOINT_CACHE=
function find_mount_point() {
	local cursor="$1"
	if [[ -n $_MOUNTPOINT_CACHE ]] && [[ $cursor == "$_MOUNTPOINT_CACHE"* ]]; then
		echo "$_MOUNTPOINT_CACHE"
		return
	fi

	while [[ $cursor != "/" ]]; do
		if mountpoint -q "$cursor"; then
			_MOUNTPOINT_CACHE="$cursor"
			echo "$_MOUNTPOINT_CACHE"
			return
		fi
		cursor=$(dirname "$cursor")
	done

	die "Can not find mount point for $1, using --root=<dir> to specify the root directory"
}

################### repair subcommand ###################
execute_describe_subcommand repair "通过查找文件名，尝试修复符号链接"
function usage_repair() {
	writeln "可指定多个符号链接或目录，默认处理当前目录"
	writeln '--root=/dir    指定find命令根目录，默认为向上查找挂载点，但不允许使用“/”'
}
function execute_repair() {
	local root
	arguments_optional_value root '--root' ''
	arguments_finalize

	# echo "root=$root"

	if [[ ${#ARGUMENTS_POSITIONAL[@]} -eq 0 ]]; then
		_execute_repair "$(pwd)"
	else
		arguments_each_positional _execute_repair
	fi
}
function _execute_repair() {
	local target="$1"
	target=$(realpath "$target")
	# 实际修复符号链接的逻辑应在这里实现
	echo "Repairing symlink: $target with root=$root"

	if [[ -z $root ]]; then
		root=$(find_mount_point "$target")
		debug "Found mount point: $root"
	fi

	local -a broken_symlinks replacements
	mapfile -t broken_symlinks < <(find "$target" -mindepth 1 -maxdepth 1 -xtype l)
	info "Found ${#broken_symlinks[@]} broken symlinks"
	for broken_symlink in "${broken_symlinks[@]}"; do
		warning "Broken symlink: $broken_symlink"
		indent

		_repair_symlink "$broken_symlink" "$root"

		indent-
	done
}
function _repair_symlink() {
	local broken_symlink="$1" root="$2" original_content answer replacements relative

	original_content=$(readlink "$broken_symlink")
	debug "original content: $original_content"

	base_name=$(basename "$original_content")
	mapfile -t replacements < <(find "$root" -name "$base_name" -a -not -path "$broken_symlink")
	debug "Found ${#replacements[@]} replacements"
	if [[ ${#replacements[@]} -gt 1 ]]; then
		answer=$(ask_select "${replacements[@]}")
	elif [[ ${#replacements[@]} -eq 1 ]]; then
		answer="${replacements[0]}"
	else
		error "No replacements found."
		return
	fi

	relative=$(realpath "--relative-to=$(dirname "$broken_symlink")" "--relative-base=$root" "$answer")
	debug "relative path: $relative"

	debug_exec ln -sf "$relative" "$broken_symlink"
}
function ask_select() {
	local options=("$@")
	local PS3="choose an option: "
	select opt in "${options[@]}"; do
		if [[ -n $opt ]]; then
			echo "$opt"
			return 0
		fi
	done
	return 1
}

################### mv subcommand ###################
execute_describe_subcommand mv "移动相对符号链接"
function usage_mv() {
	writeln "original    需要移动的符号链接"
	writeln "destination 目标位置(必须是已存在的目录)"
}
function execute_mv() {
	arguments_finalize
	if [[ ${#ARGUMENTS_POSITIONAL[@]} -ne 2 ]]; then
		usage_mv "Accepted 2 arguments: original and destination"
		return 1
	fi

	local symlink_file destination
	symlink_file="${ARGUMENTS_POSITIONAL[0]}"
	destination="${ARGUMENTS_POSITIONAL[1]}"
	if [[ ! -d $destination ]]; then
		error "Destination must be an existing directory"
		return 1
	fi
	debug "Moving symlink: $symlink_file to $destination"
	
	local original_content
	original_content=$(readlink "$symlink_file")
	if [[ $original_content != ./* ]] && [[ $original_content != ../* ]]; then
		error "Original symlink is not relative"
		return 1
	fi
	
	local pointed_to dir
	dir=$(dirname "$symlink_file")
	pointed_to=$(realpath --no-symlinks "$dir/$original_content")
	debug "pointed to: $pointed_to"
	if ! [[ -e $pointed_to ]]; then
		warning "Target of the symlink does not exist: $pointed_to"
		return 1
	fi

	relative=$(realpath "--relative-to=$destination" "$pointed_to")
	debug "relative path: $relative"
	debug_exec ln -sf "$relative" "$destination/$(basename "$symlink_file")"
	debug_exec unlink "$symlink_file"
}

execute_subcommands "$@"
