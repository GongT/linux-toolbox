#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

AP=""
AS=""
if [[ -t 2 ]]; then
	AP="\e[38;5;14m"
	AS="\e[0m"
fi

alert_cn() {
	echo -e " ⚠️  ${AP}缺少 USER_DISPLAYNAME、USER_EMAIL 环境变量，将使用系统默认值，注意检查状态。${AS}" >&2
}
alert_en() {
	echo -e " ⚠️  ${AP}Missing USER_DISPLAYNAME and USER_EMAIL environment variables, using system default, please check status.${AS}" >&2
}

has_user_and_email() {
	git config --get user.name >/dev/null 2>&1 && git config --get user.email >/dev/null 2>&1
}

export GIT_AUTHOR_NAME="${USER_DISPLAYNAME-}"
export GIT_AUTHOR_EMAIL="${USER_EMAIL-}"
export GIT_COMMITTER_NAME="${USER_DISPLAYNAME-}"
export GIT_COMMITTER_EMAIL="${USER_EMAIL-}"

ARGS=("$@")
if [[ " $* " == *' commit '* ]]; then
	if [[ -z ${GIT_AUTHOR_NAME-} ]] || [[ -z ${GIT_AUTHOR_EMAIL-} ]] && ! has_user_and_email; then
		if [[ -z ${DISPLAY-} && -z ${SSH_CONNECTION-} && ${TERM-} == 'linux' ]]; then
			alert_en
		else
			alert_cn
		fi
	fi
fi

action_large_files() {
	"${GIT_BIN}" rev-list --objects --all |
		"${GIT_BIN}" cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
		sed -n 's/^blob //p' |
		sort --numeric-sort --key=2 |
		cut -c 1-12,41- |
		$(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
}

if [[ ${1-} == 'large' ]]; then
	declare -i TAIL=${2-0}
	if [[ ${TAIL-} -gt 0 ]]; then
		action_large_files | tail -n "${TAIL}"
	else
		action_large_files
	fi
	exit 0
fi

exec "${GIT_BIN}" "${ARGS[@]}"
