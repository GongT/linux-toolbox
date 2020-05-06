#!/usr/bin/env bash

if ! command_exists journalctl ; then
	return 0
fi

copy_bin bin/logcat.sh logcat
copy_bin bin/logtail.sh logtail
