#!/bin/bash

emit "export SYSTEM_PACKAGE_MANAGER=dnf"
emit "function package-manager-make-cache {
	sudo dnf makecache
}"

dnf_config() {
	local K="$1" V="$2"
	if grep --quiet --fixed-strings --ignore-case "$1=" /etc/dnf/dnf.conf; then
		return
	fi

	echo "$K=$V" >>/etc/dnf/dnf.conf
}

dnf_config clean_requirements_on_remove True
dnf_config best False
dnf_config keepcache True
dnf_config exit_on_lock True
dnf_config ip_resolve 4
dnf_config proxy ''
dnf_config max_parallel_downloads 10
dnf_config install_weak_deps False
dnf_config cachedir /var/cache/dnf
dnf_config gpgcheck 1
dnf_config installonly_limit 3
dnf_config skip_if_unavailable True
dnf_config fastestmirror True

function install_microsoft() {
	local BASE_URL="https://packages.microsoft.com"
	local REPOS=("microsoft-fedora$(lsb-release -s -r)-prod" "microsoft-rhel9.0-prod" "vscode" "edge")
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	for REPO in "${REPOS[@]}"; do
		local REPO_URL="$BASE_URL/yumrepos/$REPO/config.repo"
		local ID="$REPO"

		ID=${ID#microsoft-}
		ID=${ID%-prod}
		
		sudo dnf config-manager addrepo \
			--from-repofile "$REPO_URL" \
			"--save-filename=microsoft-${ID}.repo"
	done
}
# install_microsoft #TODO
