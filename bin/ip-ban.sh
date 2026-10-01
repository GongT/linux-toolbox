#!/usr/bin/env bash

IP=$1

if [ "$2" = "-r" ]; then
	RELEASE=yes
fi
if [ -z "$IP" ]; then
	echo "Usage: ip-ban x.x.x.x [-r]"
fi
if ! echo "$IP" | grep -qE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' ; then
	echo "'$IP' is not a valid ip address"
fi

if [ -z "${RELEASE}" ]; then
	if ! iptables -L INPUT -n | grep "$IP" | grep -q "DROP" ; then
		iptables -A INPUT -s "$IP/32" -j DROP
	fi
else
	LINE=$(iptables -L INPUT -n --line-numbers | grep "$IP" | grep "DROP")
	[ $? -eq 0 ] || exit
	INDEX=$(echo "$LINE" | awk '{print $1}')
	iptables -D INPUT "${INDEX}"
fi
