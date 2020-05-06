#!/bin/bash

if [[ "$*" = "on" ]]; then
	if [[ -z "$PROXY" ]]; then
		echo "environment variable PROXY is not set.">&2
		echo "   use proxy set before this.">&2
	else
		export https_proxy=${PROXY} http_proxy=${PROXY} all_proxy=${PROXY} HTTPS_PROXY=${PROXY} HTTP_PROXY=${PROXY} ALL_PROXY=${PROXY} NO_PROXY="10.*,192.*,127.*,172.*"
		echo "Using proxy server $PROXY" >&2
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
	if [[ -z "$HTTP_PROXY" ]]; then
		echo "Proxy is not set" >&2
	else
		if curl -v google.com 2>&1 | grep -q 'www\.google\.com' ; then
			echo -e "\e[38;5;10mProxy is working.\e[0m"
		else
			echo -e "\e[38;5;9mProxy is NOT working.\e[0m"
		fi
	fi
else
	echo -e "not support: $*" >&2
	echo -e "Usage: proxy [on|off|set|get|test]" >&2
fi
