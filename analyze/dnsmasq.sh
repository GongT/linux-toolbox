#!/bin/bash

stdbuf -oL journalctl --since "1 day ago" -u rsyslog | \
	grep dnsmasq | \
	grep -oE 'forwarded .+ to .+' | \
	awk '{print $2" "$4}' | {
		declare -A COUNTING
		while IFS= read -r LINE ; do
			P=${COUNTING[$LINE]-0}
			COUNTING[$LINE]=$((P + 1))
		done

		for I in "${!COUNTING[@]}" ; do
			echo "${COUNTING[$I]} ${I}"
		done
	}

