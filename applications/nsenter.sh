#!/usr/bin/env bash

if command_exists nsenter ; then
	copy_bin bin/rootns.sh rootns
	copy_bin bin/umount-all.sh umount-all
fi
