#!/bin/bash

if ! command_exists dnf ; then
	return 0
fi

DNF=`which dnf`
emit "alias dnf=\"fedora_dnf_wrap '${DNF}'\""
copy_bin bin/fedora_dnf_wrap
