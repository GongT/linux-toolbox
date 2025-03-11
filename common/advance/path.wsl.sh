declare -xr ORIGINAL_PATH=$PATH
PATH=$(echo "${ORIGINAL_PATH}" | sed -E 's#(:|^)/mnt/[^:]+##g')
