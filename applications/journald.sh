#!/usr/bin/env bash

if ! command_exists journalctl ; then
	return 0
fi

copy_bin bin/logcat
copy_bin bin/logtail

