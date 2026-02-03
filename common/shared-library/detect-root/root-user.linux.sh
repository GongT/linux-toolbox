function is_root() {
	[[ $UID -eq 0 ]]
}
export SUDO=$(is_root && echo "" || echo "sudo --preserve-env ")
if is_root; then
	_SUDO=()
else
	_SUDO=(sudo --preserve-env)
fi
