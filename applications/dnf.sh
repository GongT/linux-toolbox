#!/bin/bash

cru d "system-upgrade" "dnf-makecache"

if ! command_exists dnf; then
	return 0
fi

DNF=$(find_command dnf)
emit "alias dnf=\"${VAR_HERE}/bin/fedora_dnf_wrap '${DNF}'\""

copy_bin bin/mdnf
copy_libexec staff/mdnf_inner.sh
