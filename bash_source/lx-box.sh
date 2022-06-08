#!/bin/bash

function update {
	bash ${MY_SCRIPT_ROOT}/install_environment.sh
	echo "really starting..."
	local -r _INSTALL_LEVEL_=1
	source /etc/profile.d/51-linux-toolbox.sh
	echo "Done."
}











case "${1-not set}" in
update)
	update
;;
upgrade)

;;
*)
	echo "Usage: linux-toolbox <command>"
	echo " Commands:"
	echo "    update           refresh linux-toolbox install"
	echo "    upgrade          update version of linux-toolbox"
	return 1
;;
esac
