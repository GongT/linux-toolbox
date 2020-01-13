#!/bin/bash

if [ -z "$SSH_CLIENT" ] ; then
	return
fi

SSH_CLIENT_IP=$(echo "${SSH_CLIENT}" | grep -E '^\S+' -o)
echo -n ${SSH_CLIENT_IP}
