#!/usr/bin/env bash

if _command_exists go; then
	copy_bin_with_env "GOLANG=$(_find_command go)" bin/golang.bin.sh go
fi
