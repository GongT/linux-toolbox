#!/usr/bin/env bash

if ! command_exists go; then
	return
fi

warp_bin_with_env go bin/golang.bin.sh \
	"GOLANG=$(find_command go)"

emit_stdin <<'EOF'
export GOCACHE="${SYSTEM_COMMON_CACHE:-/var/cache}/golang"
export GOMODCACHE="${SYSTEM_COMMON_CACHE:-/var/cache}/golang.mod"
export GO111MODULE=auto
export GOPROXY='https://proxy.golang.org'
# GOPROXY=https://goproxy.io,direct
EOF
