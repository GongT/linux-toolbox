#!/bin/bash


ITEMS=`ps T | tail -n +3 | awk '{print $1}'`
if [ -n "${ITEMS}" ]; then
	echo "kill $@ -- ${ITEMS}"
	kill "$@" -- ${ITEMS}
fi
