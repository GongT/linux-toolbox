if ! command_exists wg; then
	return 0
fi

WG=$(find_command wg)
warp_bin_with_env wg bin/wg_wrap.sh \
	"WG=${WG}"
