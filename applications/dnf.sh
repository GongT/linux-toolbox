#!/bin/bash

if ! command_exists dnf; then
	cru d "system-upgrade" "dnf-makecache"
	return 0
fi

DNF=$(find_command dnf)
emit "alias dnf=\"${VAR_HERE}/bin/fedora_dnf_wrap '${DNF}'\""

if command_exists crontab; then
	cru a "system-upgrade" "0 6 * * 4 $DNF upgrade -y" "每周四凌晨6点升级系统"
	cru a "dnf-makecache" "0 5 * * * $DNF makecache" "每天凌晨5点刷新dnf缓存"
fi
