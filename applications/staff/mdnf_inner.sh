#!/usr/bin/bash

cd "${INSTALL_ROOT}"

mount --bind /proc "${INSTALL_ROOT}/proc"
mount --bind /dev "${INSTALL_ROOT}/dev"
mount --bind /sys "${INSTALL_ROOT}/sys"

declare -a DNF_ARGS=(
	"--installroot=${INSTALL_ROOT}"
	"--nodocs"
	"--setopt=install_weak_deps=False"
	"--setopt=clean_requirements_on_remove=True"
	"--setopt=keepcache=True"
	"--setopt=exit_on_lock=True"
	"--setopt=max_parallel_downloads=10"
	"--setopt=best=False"
	"--setopt=skip_if_unavailable=False"
)

if ! [[ -e "${INSTALL_ROOT}/etc/os-release" ]]; then
	source /etc/os-release
	DNF_ARGS+=("--releasever=${VERSION_ID}")
fi

if [[ $* == bash ]]; then
	exec env "PS1=[DNF \W]# " bash --login --norc --noprofile -i
fi

x() {
	printf '\e[2m + %s\e[0m\n' "$*" >&2
	exec "$@"
}

# /usr/bin/ls -lA /tmp/xxx/etc/yum.repos.d
x /usr/bin/dnf "${DNF_ARGS[@]}" "$@"
