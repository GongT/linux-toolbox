#!/bin/sh

emit "export SYSTEM_PACKAGE_MANAGER=dnf"
emit "function package-manager-make-cache {
	dnf makecache
}"

if ! grep -q "keepcache" /etc/dnf/dnf.conf; then
	echo "
clean_requirements_on_remove=True
keepcache=True
exit_on_lock=True
# ip_resolve=4
# proxy=
max_parallel_downloads=10
install_weak_deps=False
cachedir=/var/cache/dnf
" >> /etc/dnf/dnf.conf
fi
