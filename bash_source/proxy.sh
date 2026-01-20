#!/bin/bash

init_noproxy_if_not_set() {
	if [[ -z "${NO_PROXY:-}" ]]; then
		envfile-system NO_PROXY "10.*,192.*,127.*,172.*,10.0.0.0/8,127.0.0.0/8,172.0.0.0/8,192.0.0.0/8,::1,localhost,localdomain,local,internal" >&2
	fi
}

if [[ $* == "on" ]]; then
	if [[ -z ${PROXY:-} ]]; then
		echo "environment variable PROXY is not set." >&2
		echo "   use proxy set before this." >&2
	else
		export https_proxy=${PROXY} http_proxy=${PROXY} all_proxy=${PROXY} HTTPS_PROXY=${PROXY} HTTP_PROXY=${PROXY} ALL_PROXY=${PROXY}
		echo "Using proxy server $PROXY" >&2
		init_noproxy_if_not_set
		SEP=, list dedup NO_PROXY
		export NO_PROXY
		export no_proxy="$NO_PROXY"
	fi
elif [ "$*" = "off" ]; then
	unset https_proxy http_proxy all_proxy HTTPS_PROXY HTTP_PROXY ALL_PROXY

	echo "Proxy server unset." >&2
elif [ "$1" = "get" ]; then
	echo "$PROXY"
elif [ "$1" = "set" ]; then
	envfile-system PROXY "$2"
	export PROXY="$2"
	init_noproxy_if_not_set
elif [ "$*" = "test" ]; then
	if [[ -z $HTTP_PROXY ]]; then
		echo "Proxy is not set" >&2
	else
		if curl -v google.com 2>&1 | grep -q 'www\.google\.com'; then
			echo -e "\e[38;5;10mProxy is working.\e[0m"
		else
			echo -e "\e[38;5;9mProxy is NOT working.\e[0m"
		fi
	fi
elif [ "$1" = "no" ]; then
	shift
	init_noproxy_if_not_set
	if [[ $1 == "add" ]]; then
		SEP=',' list add NO_PROXY "$2"
	elif [[ $1 == "del" ]]; then
		SEP=',' list del NO_PROXY "$2"
	elif [[ $1 == "dump" ]]; then
		SEP=',' list dump NO_PROXY
		return
	else
		echo -e "not support: $1" >&2
		echo -e "Usage: proxy no [add url|del url|dump]" >&2
		return 1
	fi
	SEP=, list dedup NO_PROXY
	envfile-system NO_PROXY "$NO_PROXY"
	# export NO_PROXY="$NO_PROXY"
else
	echo -e "not support: $*" >&2
	echo -e "Usage: proxy [on|off|set|get|test|no [add|del|dump]]" >&2
	return 1
fi


unset SEP
unset -f init_noproxy_if_not_set
