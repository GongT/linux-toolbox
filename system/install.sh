#!/usr/bin/env bash

SYSTEM_PM_INSTALL_SUBCOMMAND="install -y"

if command_exists apt-get; then
	install_script package-manager apt-get
elif command_exists dnf; then
	install_script package-manager dnf
elif command_exists pacman; then
	install_script package-manager pacman
elif command_exists cygpath.exe; then
	install_script package-manager cygwin
else
	die "\nonly support apt-get | pacman | dnf."
fi

function require_command_in_package() {
	local COMMAND=$1
	local PACKAGE_NAME=$2
	local STANDARD_PATHS=("/usr/bin" "/usr/local/bin" "/bin")

	local PREFIX

	for PREFIX in "${STANDARD_PATHS[@]}"; do
		if [[ -e "${PREFIX}/${COMMAND}" ]]; then
			debug "command $COMMAND: exists"
			return 0
		fi
	done

	if [[ -n "${PACKAGE_NAME}" ]]; then
		warning "command '$COMMAND' not found, try install..."
		"${SYSTEM_PACKAGE_MANAGER}" "${SYSTEM_PM_INSTALL_SUBCOMMAND}" "${PACKAGE_NAME}" ||
			die "can't install package '${PACKAGE_NAME}'"
		require_command_in_package "${COMMAND}"
	else
		die "missing required command '${COMMAND}' you must install it manually."
	fi
}

if grep -q "debian" /etc/os-release 2>/dev/null; then
	install_script distribute debian
elif grep -q "Arch Linux" /etc/os-release 2>/dev/null; then
	install_script distribute arch
elif [[ -e "/etc/redhat-release" ]]; then
	install_script distribute rhel
elif command_exists cygpath.exe; then
	install_script distribute cygwin
else
	die "\nonly support debian | rhel-based linux Or cygwin."
fi

require_command_in_package vim vim

unset require_command_in_package SYSTEM_PM_INSTALL_SUBCOMMAND

if command_exists systemctl >/dev/null; then
	install_script init-process systemd
elif [ -e /bin/cygpath.exe ]; then
	echo "skip init helpers on cygwin"
else
	die "\nonly support systemd."
fi

if grep -q -i 'microsoft' /proc/version; then
	emit '
function unix_mount_path {
	echo $1 | sed "s/^\([A-Z]\):/\L\/mnt\/\1/g" | sed "s/\\\\/\//g"
}

'
fi
