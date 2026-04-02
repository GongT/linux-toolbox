#!/usr/bin/env bash

CURL=/usr/bin/curl

ARGSTR="$*"
# 从参数列表中查找指定的参数
find_arg() {
	for arg in "$@"; do
		if [[ " $ARGSTR " == *" $arg "* ]]; then
			return 0
		fi
	done
	return 1
}

ARGS=("$@")

# 禁止重试
ARGS+=("--retry" "0")

if ! find_arg --max-time -m; then
	ARGS+=("--max-time" "30")
fi

DEFARGS=("${ARGS[@]}")
if ! find_arg --range && ! find_arg -r; then
	# 只要没有指定 range 参数，就启用断点续传功能
	ARGS+=("--continue-at" "-")
fi

if [[ $ARGSTR == *"api.github.com"* ]] && [[ $ARGSTR != *" Authorization:"* ]]; then
	if [[ -e ~/.github_token ]]; then
		GITHUB_TOKEN=$(<~/.github_token)
	elif [[ -n ${GITHUB_TOKEN-} ]]; then
		: # 已经在环境变量中设置了 GITHUB_TOKEN
	else
		echo "Personal access token can be placed in ~/.github_token or set the GITHUB_TOKEN environment variable." >&2
	fi

	if [[ -n ${GITHUB_TOKEN-} ]]; then
		ARGS=(-H "Authorization: Bearer $GITHUB_TOKEN" "${ARGS[@]}")
	fi
fi

declare -i RET=-1
declare -i LEFT_RETRIES=20

if [[ ${FOREVER-} == "true" ]] || [[ ${FOREVER-} == "1" ]] || [[ ${FOREVER-} == "yes" ]]; then
	LEFT_RETRIES=-1
fi

while [[ $LEFT_RETRIES -ne 0 ]]; do
	"$CURL" "${ARGS[@]}"
	RET=$?

	echo "[curl] exit code: $RET" >&2
	LEFT_RETRIES="$LEFT_RETRIES - 1"

	if [[ $RET -eq 35 || $RET -eq 56 ]]; then
		# 35 - SSL connect error. The SSL handshaking failed.
		# 56 - Failure with receiving network data.
		sleep 1
		continue
	fi

	if [[ $RET -eq 33 ]]; then
		# 33 - HTTP range error. The range "command" did not work.
		ARGS=("${DEFARGS[@]}")
		continue
	fi

	exit $RET
done

exit 0
