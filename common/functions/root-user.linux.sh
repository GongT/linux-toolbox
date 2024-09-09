function is_root() {
	[[ $UID -eq 0 ]]
}
export SUDO=$(is_root && echo "" || echo "sudo --preserve-env ")
