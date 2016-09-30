#!/usr/bin/env bash

ensure_command wget
ensure_command tar
ensure_command xz

NODE_PACKAGE=`curl -s https://nodejs.org/dist/latest/ | grep -oE 'node-v[0-9\\.]+-linux-x64\.tar\.xz' | tail -1`

if [ -z "${NODE_PACKAGE}" ]; then
	echo "can't find latest version"
	return 1
fi


try_unzip () {
	tagged_run "unzip nodejs" tar xf "/tmp/${NODE_PACKAGE}" -C nodejs-install/
}
try_download () {
	IGNORE_STD_ERROR=yes \
	echo "download nodejs binary"
	wget -nv --show-progress "https://nodejs.org/dist/latest/${NODE_PACKAGE}" -O "/tmp/${NODE_PACKAGE}"
}

if [ ! -f "/tmp/${NODE_PACKAGE}" ]; then
	try_download
fi

cd /tmp

mkdir -p nodejs-install/

try_unzip || try_download && try_unzip
cd nodejs-install/*

cp -r bin include lib share /usr
