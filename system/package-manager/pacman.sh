#!/bin/sh

emit "export SYSTEM_PACKAGE_MANAGER=pacman"
emit "function package-manager-make-cache {
	echo -n ''
}"

export SYSTEM_PACKAGE_MANAGER=pacman

emit_alias_sudo pacman --noconfirm
export SYSTEM_PM_INSTALL_SUBCOMMAND="--noconfirm -S"
