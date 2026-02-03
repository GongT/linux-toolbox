if ! command_exists wg; then
	return 0
fi

WG=$(find_command wg)
copy_bin bin/wg_wrap.sh wg \
	"WG=${WG}"
