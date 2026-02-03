#!/bin/bash

emit "export INIT_PROCESS=systemd"
export INIT_PROCESS=systemd

emit "# systemctl-journalctl.sh"
emit_file bin/systemctl-journalctl.sh

emit_alias_sudo "networkctl"
emit 'complete -o default -o nospace -F _systemctl s
source /usr/share/bash-completion/completions/systemctl
alias s="systemctl"'

function copy_systemd_unit() {
	local SERVICE_NAME="$1" CONTENT LIBRARY
	shift
	local SOURCE_FILE="${HERE}/services/${SERVICE_NAME}"
	local TARGET_DIR="/usr/local/lib/systemd/system"

	CONTENT=$(<"${SOURCE_FILE}")

	LIBRARY="services/$(basename "${SERVICE_NAME}" .service).sh"
	if [[ -f "${HERE}/${LIBRARY}" ]]; then
		local INSTALLED_LIBRARY=""
		INSTALLED_LIBRARY=$(copy_library "${LIBRARY}")
		CONTENT=$(echo "${CONTENT}" | sed "s#__SCRIPT__#${INSTALLED_LIBRARY}#g")
	fi

	write_file_if_changed "${TARGET_DIR}/${SERVICE_NAME}" "$CONTENT"
	debug "create systemd unit: ${SERVICE_NAME} - ${LAST_FILE_CHANGED}"
}

copy_systemd_unit "software-update-before-shutdown.service"
