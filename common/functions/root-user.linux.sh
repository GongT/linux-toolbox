function is_root() {
	[[ "$(id -u)" -eq 0 ]]
}
export SUDO=$(is_root && echo "" || echo "sudo ")
