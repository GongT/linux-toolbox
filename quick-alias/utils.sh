#!/bin/bash

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -lhA --color=auto'
alias la='ls -hA --color=auto'
alias vi='vim'

export SSH_CLIENT_IP=$(echo "${SSH_CLIENT}" | awk '{print $1}')

if [ -z "${DISPLAY}" ]; then
	export DISPLAY="${SSH_CLIENT_IP}:0"
fi
