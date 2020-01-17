#!/bin/bash

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ll='LC_ALL=zh_CN.UTF-8 ls -hAl'
alias la='LC_ALL=zh_CN.UTF-8 ls -hA'
alias vi='vim'

export SSH_CLIENT_IP=$(echo "${SSH_CLIENT}" | awk '{print $1}')

if [ -z "${DISPLAY}" ]; then
	export DISPLAY="${SSH_CLIENT_IP}:0"
fi
