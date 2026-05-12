#!/bin/bash

ARGS=("$@")
if [ ${#ARGS[@]} -eq 0 ]; then
	ARGS=(.env.*)
fi

echo "加载到环境变量:" >&2
set -a
for __file in "${ARGS[@]}"; do
	echo " - $__file" >&2
	# shellcheck disable=SC1090
	source "${__file}"
done
set +a

unset __file
