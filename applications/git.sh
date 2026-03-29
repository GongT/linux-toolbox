if ! command_exists git; then
	return 0
fi

GIT_BIN=$(find_command git)
copy_bin bin/git_wrap.sh git \
	"GIT_BIN=${GIT_BIN}"

emit_file alias/git.sh

git() {
	if ! "${GIT_BIN}" "$@"; then
		printf "\x1B[38;5;14mgit command failed:\x1B[0m git %s\n" "$*" >&2
		return 1
	fi
}

if git config --system get http.proxy 2>&1 | grep -q 'key does not contain a section: get'; then
	git_config_set() {
		local location="$1" field="$2" value="$3"
		git config "$location" --replace-all "$field" "$value"
	}
	git_config_unset() {
		local location="$1" field="$2" value="$3"
		git config "$location" --unset-all "$field" "$value"
	}
else
	git_config_set() {
		local location="$1" field="$2" value="$3"
		git config "$location" set --all "$field" "$value"
	}
	git_config_unset() {
		local location="$1" field="$2" value="$3"
		git config "$location" unset --all "$field" "$value"
	}
fi

single_configure_user() {
	local field="$1" value="$2"
	git_config_unset --system "$field" &>/dev/null || : # 删除key如果不存在，会返回错误，需要忽略
	git_config_set --global "$field" "$value"
}

single_configure_system() {
	local field="$1" value="$2"

	if ! is_root; then
		single_configure_user "$field" "$value"
		return
	fi
	git_config_unset --global "$field" &>/dev/null || : # 删除key如果不存在，会返回错误，需要忽略
	git_config_set --system "$field" "$value"
}

remove_configure() {
	local field="$1"
	git_config_unset --system "$field" &>/dev/null || :
	git_config_unset --global "$field" &>/dev/null || :
}

single_configure_single_user() {
	local field="$1" value="$2"
	if is_single_user_mode; then
		single_configure_system "$field" "$value"
	else
		single_configure_user "$field" "$value"
	fi
}

has_config() {
	git config get "$1" &>/dev/null
}

remove_configure user.name
remove_configure user.email

single_configure_user pull.rebase true
single_configure_system push.default upstream
single_configure_system push.autoSetupRemote true
single_configure_system core.autocrlf input
single_configure_system core.eof lf
single_configure_system "url.https://.insteadOf" "git://"
single_configure_system init.defaultBranch master
single_configure_system fetch.recurseSubmodules true
single_configure_system filter.lfs.clean "git-lfs clean -- %f"
single_configure_system filter.lfs.smudge "git-lfs smudge -- %f"
single_configure_system filter.lfs.process "git-lfs filter-process"
single_configure_system filter.lfs.required true
single_configure_user credential.helper "store --file ${HOME}/.config/gitpassword"

CMD=$(
	cat <<-'LINE'
		!git submodule foreach --quiet --recursive 'git reset --quiet --hard ; git clean --quiet -ffdx' && git submodule foreach 'git checkout --progress --force "$(git config --file "$toplevel/.gitmodules" --get "submodule.$name.branch")"'
	LINE
)
single_configure_system alias.scheckout "$CMD"

CMD=$(
	cat <<-'LINE'
		!git submodule foreach --quiet --recursive 'git reset --quiet --hard ; git clean --quiet -ffdx' && git submodule foreach 'git checkout --progress --force "$(git config --file "$toplevel/.gitmodules" --get "submodule.$name.branch")" && git pull'
	LINE
)
single_configure_system alias.spull "$CMD"
