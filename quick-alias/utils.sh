#!/bin/bash

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls --color=auto'
alias l.='LC_ALL=zh_CN.UTF-8 ls -d .* --color=auto'
alias ll='LC_ALL=zh_CN.UTF-8 ls -lhA --color=auto'
alias la='LC_ALL=zh_CN.UTF-8 ls -hA --color=auto'
alias vi='vim'

export SSH_CLIENT_IP=$(echo "${SSH_CLIENT}" | awk '{print $1}')

if [ -z "${DISPLAY}" ]; then
	export DISPLAY="${SSH_CLIENT_IP}:0"
fi
