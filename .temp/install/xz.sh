#!/usr/bin/env bash

if [ "${SYSTEM}" == "debian" ]; then
	system_install xz-utils
else
	system_install xz
fi
