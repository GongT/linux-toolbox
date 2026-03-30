#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

VERSIONS_DIR=/opt/claude/versions
CURRENT_VERSION=''
ORIGINAL_BIN=~/.local/bin/claude

find_current_version() {
	local LATEST_FILE
	LATEST_FILE=$(
		find "${VERSIONS_DIR}" -mindepth 1 -maxdepth 1 -type f -print0 |
			sort -zV |
			tail -zn1
	)
	CURRENT_VERSION=$(basename "${LATEST_FILE}")
}

clean() {
	if [[ -e ${ORIGINAL_BIN} || -L ${ORIGINAL_BIN} ]]; then
		unlink "${ORIGINAL_BIN}"
	fi
}

### current user first use
if [[ ! -L ~/.local/share/claude/versions ]]; then
	if [[ -d ~/.local/share/claude/versions ]]; then
		cp -r ~/.local/share/claude/versions "$(dirname "${VERSIONS_DIR}")"
		rm -rf ~/.local/share/claude/versions
	fi
	mkdir -p ~/.local/share/claude
	ln -s "${VERSIONS_DIR}" ~/.local/share/claude/versions
	clean

	if [[ -e ~/.claude && ! -L ~/.claude ]]; then
		mv ~/.claude ~/.claude.bak
	fi
	ln -s /opt/claude/home/.claude ~/.claude

	if [[ -e ~/.claude.json && ! -L ~/.claude.json ]]; then
		mv ~/.claude.json ~/.claude.json.bak
	fi
	ln -s /opt/claude/home/.claude.json ~/.claude.json
fi

### first install claude
if [[ ! -d ${VERSIONS_DIR} ]] || ! find_current_version 2>/dev/null; then
	echo "No versions of Claude found."
	proxy on

	mkdir -p "${VERSIONS_DIR}" /opt/claude/home/.claude
	if [[ ! -e /opt/claude/home/.claude.json ]]; then
		echo '{}' >/opt/claude/home/.claude.json
	fi

	chmod -R ug+w "${VERSIONS_DIR}" /opt/claude/home
	find /opt/claude/home -type d -exec chmod ug+x {} \;

	wget -O - https://claude.ai/install.sh | bash

	clean
	find_current_version
fi

### execute the current version

set +Ee

"${VERSIONS_DIR}/${CURRENT_VERSION}" "$@"
R=$?

clean

exit "${R}"
