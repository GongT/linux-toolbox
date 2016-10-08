#!/bin/bash

if ! command_exists docker ; then
	return 0
fi

copy_bin bin/dps
