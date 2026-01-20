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

exec "${GIT_BIN}" "${ARGS[@]}"
