#!/usr/bin/env bash

if ! command_exists node ; then
	return 0
fi

copy_bin bin/update-nodejs
