#!/bin/bash

cru d "system-upgrade" "dnf-makecache"

if ! command_exists dnf; then
	return 0
fi

DNF=$(find_command dnf)
copy_bin bin/fedora_dnf_wrap.sh dnf \
	"DNF=${DNF}"

copy_bin bin/mdnf
copy_library staff/mdnf_inner.sh >/dev/null
