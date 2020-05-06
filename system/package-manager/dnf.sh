#!/bin/sh

emit "export SYSTEM_PACKAGE_MANAGER=dnf"
emit "function package-manager-make-cache {
	dnf makecache
}"
