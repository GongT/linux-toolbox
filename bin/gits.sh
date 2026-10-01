#!/bin/bash

export LANG=C
export LOG_LOCAL="`pwd`/gits-debug.log"
echo -n '' > "${LOG_LOCAL}"

function die {
	echo "$@" >&2
	echo "DIE: " >> "${LOG_LOCAL}"
	echo "  $@" >> "${LOG_LOCAL}"
	return 1
}
function prevent_mistake {
	if [ -e "/etc/deploy-server" ]; then
		source /etc/deploy-server
		return "${IS_DEPLOY_SERVER-0}"
	fi
	read -p "this action is very danger, please type uppercase \"YES\" to continue." YES
	if [ "${YES}" != "YES" ]; then
		echo "abort." >&2
		return 1
	fi
}
function push {
	git fetch || die "can't fetch remote" || return 1
	git add .
	git commit
	git push
}
function cleanup {
	git clean -d -f
}
function reset {
	git reset --hard
	git clean -d -f
}
function status {
	local OUT=$(git -c color.status=always status -s)
	local EXCODE=$?
	
	if [ ${EXCODE} -ne 0 ]; then
		echo -e "\e[1m${GITS_FOLDER_NAME}\e[0m - \e[38;5;9mERROR\e[0m"
		return
	fi
	
	local CHANGED_FILES=$(echo "${OUT}" | wc -l)
	if [ "${CHANGED_FILES}" -eq 0 -o "${OUT}" = "" ]; then
		if git status 2>&1 | grep -q "branch is ahead of" ; then
			echo -e "\e[1m${GITS_FOLDER_NAME}\e[0m -\e[38;5;14m git push required.\e[0m"
		else
			echo -e "\e[2m${GITS_FOLDER_NAME} - no change.\e[0m"
		fi
	else
		echo -e "\e[1m${GITS_FOLDER_NAME}\e[0m - \e[38;5;14m${CHANGED_FILES}\e[0m changes:"
		echo "${OUT}" | sed "s/^/    /g"
	fi
}
function run {
	echo -e "\e[38;5;14m${GITS_FOLDER_NAME}:\e[0m"
	"$@"
	local RET=$?
	
	if [ "${RET}" -eq 0 ]; then
		echo -e "\e[38;5;14m${GITS_FOLDER_NAME}: \e[38;5;10m√\e[0m"
	else
		echo -e "\e[38;5;14m${GITS_FOLDER_NAME}: \e[38;5;9m×\e[0m"
	fi
	return ${RET}
}
function each_folder {
	local CMD=$1
	shift
	local F
	
	local FOLDERS=0
	local FOLDERS_ERROR=()
	local RET=0

	for F in */.git/
	do
		local FOLDER=${F%/.git/}
		echo -n "* ${FOLDER}: " >> "${LOG_LOCAL}"
		
		export GITS_FOLDER_NAME="${FOLDER}"
		local LOG_NAME="`pwd`/gits-${FOLDER}.log"
		
		cd "${FOLDER}"
		
		echo "processing:" >> "${LOG_LOCAL}"
		echo "	$CMD $@" >> "${LOG_LOCAL}"
		"$CMD" "$@" 2>&1 | tee "${LOG_NAME}"
		RET=${PIPESTATUS[0]}
		echo "	complete, return ${RET}" >> "${LOG_LOCAL}"
		
		if [ "${RET}" -ne 0 ]; then
			FOLDERS_ERROR+=("${FOLDER}")
			if [ "${CONFIG_ERROR_END}" -eq 1 ]; then
				echo "exit because exit on error." >> "${LOG_LOCAL}"
				cd ..
				break
			fi
		else
			rm -f "${LOG_NAME}"
		fi
		
		cd ..
		
		FOLDERS=$((FOLDERS + 1))
	done
	
	echo "" >&2
	echo "operation done: ${FOLDERS} folders processed." >&2
	if [ "${#FOLDERS_ERROR[@]}" -eq 0 ]; then
		echo "    everything success!" >&2
	else
		echo "    ${#FOLDERS_ERROR[@]} errors occurred:" >&2
		for i in "${FOLDERS_ERROR[@]}"; do
			echo "        ${i}" >&2
		done
		echo "    check gits-xxxx.log for details" >&2
	fi
	
	echo "all complete, return ${RET}" >> "${LOG_LOCAL}"
	return ${RET}
}

CONFIG_ERROR_END=0

while true ; do
	case "$1" in
	-e)
		shift
		CONFIG_ERROR_END=1
		continue
	;;
	cmd)
		shift
		each_folder run "$@"
	;;
	each)
		shift
		each_folder run sh -c "$*"
	;;
	status)
		each_folder status
	;;
	push)
		each_folder run push
	;;
	fetchall)
		each_folder run git fetch --all
	;;
	pull)
		each_folder run git pull --ff-only
	;;
	cleanup)
		each_folder run cleanup
	;;
	reset)
		prevent_mistake || die "refuse to run."
		each_folder run reset
	;;
	*)
		cat << HELP >&2
* gits - control many git repos in current dir
	
usage:
	gits [-e] <action> [args...]
	
switch:
	-e: do not process next folder when error
	
commands:
	each: run `sh -c "args..."` in every repo
	cmd: run "args..." in every repo
	
	status: enhanced version of `git status` in all repos
	push: run `push all` in all repos
	fetchall: run `fetch --all` in all repos
	pull: run `pull` in all repos
	cleanup: run `clean -d -f` in all repos
HELP
		exit 1
	;;
	esac
	exit $?
done
