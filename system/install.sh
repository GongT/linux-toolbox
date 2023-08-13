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
	COMMAND=$1
	PACKAGE_NAME=$2

	echo -n "command $1: "
	if [[ -e "/usr/bin/${COMMAND}" ]]; then
		echo "exists"
		return 0
	elif [[ -e "/usr/local/bin/${COMMAND}" ]]; then
		echo "exists"
		return 0
	elif [[ -e "/bin/${COMMAND}" ]]; then
		echo "exists"
		return 0
	elif [[ -n "${PACKAGE_NAME}" ]]; then
		echo "not exists"
		echo "RUN:   ${SYSTEM_PACKAGE_MANAGER} ${SYSTEM_PM_INSTALL_SUBCOMMAND} ${PACKAGE_NAME} ..."
		${SYSTEM_PACKAGE_MANAGER} ${SYSTEM_PM_INSTALL_SUBCOMMAND} "${PACKAGE_NAME}" ||
			die "\e[0mcan't install command: ${COMMAND}"
		require_command_in_package "${COMMAND}"
	else
		echo -e "\e[38;5;9mfailed\e[0m"
		die "fail to install command: ${COMMAND}"
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

if [ -e /usr/lib/upstart ]; then
	install_script init-process upstart
elif command_exists systemctl >/dev/null; then
	install_script init-process systemd
elif [ -e /usr/sbin/chkconfig ] >/dev/null; then
	install_script init-process rhel-sysv
elif [ -e /bin/cygpath.exe ]; then
	echo "skip init helpers on cygwin"
else
	die "\nonly support upstart | systemd | rhel-sysv."
fi

if grep -q -i 'microsoft' /proc/version; then
	emit '
function unix_mount_path {
	echo $1 | sed "s/^\([A-Z]\):/\L\/mnt\/\1/g" | sed "s/\\\\/\//g"
}

'
fi
