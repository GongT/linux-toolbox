#!/bin/sh

emit "export SYSTEM_PACKAGE_MANAGER=yum"
emit "function package-manager-make-cache {
	yum makecache
}"

export SYSTEM_PACKAGE_MANAGER=yum
yum makecache

emit_alias_sudo yum --merge-conf --leaves-exclude-bin --remove-leaves --exclude=*.i686
