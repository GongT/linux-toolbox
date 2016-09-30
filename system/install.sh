#!/usr/bin/env bash

set -e

if [ -e /usr/bin/apt-get ]; then
	install_script package-manager apt-get
elif [ -e /usr/bin/dnf ]; then
	install_script package-manager dnf
elif [ -e /usr/bin/yum ]; then
	install_script package-manager yum
else
	die -e "\nonly support apt-get | yum | dnf."
fi


function require_command_in_package {
	COMMAND=$1
	PACKAGE_NAME=$2
	
	echo -n "command $1: "
	if [ -e "/usr/bin/${COMMAND}" ]; then
		echo "exists"
		return 0
	elif [ -e "/usr/local/bin/${COMMAND}" ]; then
		echo "exists"
		return 0
	elif [ -e "/bin/${COMMAND}" ]; then
		echo "exists"
		return 0
	elif [ -n "${PACKAGE_NAME}" ]; then
		echo "not exists"
		echo "RUN:   ${SYSTEM_PACKAGE_MANAGER} install --color always -y ${PACKAGE_NAME} ..."
		${SYSTEM_PACKAGE_MANAGER} install --color always -y "${PACKAGE_NAME}" || \
			die -e "\e[0mcan't install command: ${COMMAND}"
		require_command_in_package "${COMMAND}"
	else
		echo -e "\e[38;5;9mfailed\e[0m"
		die "fail to install command: ${COMMAND}"
	fi
}

if grep -q "debian" /etc/os-release ; then
	install_script distribute debian
elif [ -e "/etc/redhat-release" ]; then
	install_script distribute rhel
else
	die -e "\nonly support debian | rhel-based linux."
fi

require_command_in_package screen screen
require_command_in_package expect expect
require_command_in_package vim vim

unset require_command_in_package


if [ -e /usr/lib/upstart ]; then
	install_script init-process upstart
elif [ -e /usr/bin/systemctl ] > /dev/null ; then
	install_script init-process systemd
elif [ -e /usr/sbin/chkconfig ] > /dev/null ; then
	install_script init-process rhel-sysv
else
	die -e "\nonly support upstart | systemd | rhel-sysv."
fi
