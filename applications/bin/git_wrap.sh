#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

alert_cn() {
	echo -e " ⚠️  \e[38;5;14m缺少 USER_DISPLAYNAME、USER_EMAIL 环境变量，将使用系统默认值，注意检查状态。\e[0m" >&2
}
alert_en() {
	echo -e " ⚠️  \e[38;5;14mMissing USER_DISPLAYNAME and USER_EMAIL environment variables, using system default, please check status.\e[0m" >&2
}

ARGS=("$@")
if [[ " $* " == *' commit '* ]]; then
	if [[ -z ${USER_DISPLAYNAME-} ]] || [[ -z ${USER_EMAIL-} ]]; then
		if [[ -z ${DISPLAY-} && -z ${SSH_CONNECTION-} && ${TERM-} == 'linux' ]]; then
			alert_en
		else
			alert_cn
		fi
	else
		ARGS=(-c "user.name=${USER_DISPLAYNAME}" -c "user.email=${USER_EMAIL}" "${ARGS[@]}")
	fi
fi

action_large_files() {
	git rev-list --objects --all |
		git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
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
