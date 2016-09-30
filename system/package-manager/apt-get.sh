#!/bin/sh

emit "export SYSTEM_PACKAGE_MANAGER=apt-get"
emit "function package-manager-make-cache {
	apt-get update
}"

export SYSTEM_PACKAGE_MANAGER=apt
apt-get update

emit_alias_sudo "apt"
emit_alias_sudo "apt-get"
emit_alias_sudo "apt-cache"
emit_alias_sudo "dpkg"
