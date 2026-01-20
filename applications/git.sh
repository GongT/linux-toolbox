if ! command_exists git; then
	return 0
fi

emit_file alias/git.sh
copy_bin bin/git-find-large

single_configure_user() {
	local field="$1" value="$2"
	git config --system --unset --all "$field" &>/dev/null || : # 删除key如果不存在，会返回错误，需要忽略
	git config --global --replace-all "$field" "$value"
}

single_configure_system() {
	local field="$1" value="$2"

	if ! is_root; then
		single_configure_user "$field" "$value"
		return
	fi
	git config --global --unset --all "$field" &>/dev/null || : # 删除key如果不存在，会返回错误，需要忽略
	git config --system --replace-all "$field" "$value"
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

ask_user_info() {
	local email
	read -r -p "输入 git 邮箱:" email

	email="${email%% }"
	email="${email## }"

	export USER_EMAIL="$email"
}

single_configure_single_user user.name "$USER_DISPLAYNAME"
if [[ ${USER_EMAIL-} == "" ]]; then
	if has_config user.email; then
		USER_EMAIL=$(git config --get user.email || true)
	fi

	if [[ ${USER_EMAIL-} == "" ]]; then
		ask_user_info
	fi
fi
single_configure_single_user user.email "${USER_EMAIL}"

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
