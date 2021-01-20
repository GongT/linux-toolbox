#!/usr/bin/env bash

if ! _command_exists go; then
	return
fi



copy_bin_with_env "GOLANG=$(_find_command go)" bin/golang.bin.sh go

go env -w GOCACHE="${SYSTEM_COMMON_CACHE:-'/var/cache'}/golang"
go env -w GOMODCACHE="${SYSTEM_COMMON_CACHE:-'/var/cache'}/golang.mod"
go env -w GO111MODULE=auto
go env -w GOPROXY='https://proxy.golang.org'
# go env -w GOPROXY=https://goproxy.io,direct
