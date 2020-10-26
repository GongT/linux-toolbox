#!/bin/bash

if [[ $* == "on" ]]; then
	if [[ -z ${PROXY:-} ]]; then
		echo "environment variable PROXY is not set." >&2
		echo "   use proxy set before this." >&2
	else
		export https_proxy=${PROXY} http_proxy=${PROXY} all_proxy=${PROXY} HTTPS_PROXY=${PROXY} HTTP_PROXY=${PROXY} ALL_PROXY=${PROXY} NO_PROXY="10.*,192.*,127.*,172.*"
		echo "Using proxy server $PROXY" >&2
		if [[ "${NOPROXY:-}" ]]; then
			if [[ ${NO_PROXY:-} ]]; then
				export NO_PROXY="$NO_PROXY,$NOPROXY"
			else
				export NO_PROXY="$NOPROXY"
			fi
			SEP=, list normalize NO_PROXY
			export no_proxy+="$NO_PROXY"
		fi
	fi
elif [ "$*" = "off" ]; then
	unset https_proxy http_proxy all_proxy HTTPS_PROXY HTTP_PROXY ALL_PROXY NO_PROXY

	echo "Proxy server unset." >&2
elif [ "$1" = "get" ]; then
	echo "$PROXY"
elif [ "$1" = "set" ]; then
	envfile-system PROXY "$2"
	export PROXY="$2"
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
elif [ "$1" = "noproxy" ]; then
	shift
	if [[ $1 == "add" ]]; then
		SEP=',' list add NO_PROXY "$2"
	elif [[ $1 == "del" ]]; then
		SEP=',' list del NO_PROXY "$2"
	elif [[ $1 == "dump" ]]; then
		SEP=',' list dump NO_PROXY
		return
	else
		echo -e "not support: $1" >&2
		echo -e "Usage: proxy noproxy [add url|del url|dump]" >&2
	fi
	SEP=, list normalize NO_PROXY
	envfile-system NOPROXY "$NO_PROXY"
	export NOPROXY="$NO_PROXY"
else
	echo -e "not support: $*" >&2
	echo -e "Usage: proxy [on|off|set|get|test|noproxy]" >&2
fi
