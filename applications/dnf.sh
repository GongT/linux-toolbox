#!/bin/bash

if ! command_exists dnf ; then
	return 0
fi

DNF=`which dnf`
emit "alias dnf=\"${VAR_HERE}/bin/fedora_dnf_wrap '${DNF}'\""
