#!/bin/bash
# shellcheck disable=SC2139

export TIME_STYLE='+%Y-%m-%d
%H:%M:%S'

if [[ -t 2 ]]; then
	__COLORARG="--color=auto"
else
	__COLORARG=""
fi

alias l.="ls ${__COLORARG} -d .*"
alias ll="ls ${__COLORARG} -lhA"
alias la="ls ${__COLORARG} -hA"
alias vi="vim"

# Interactive operation...
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -r'             # raw control characters
alias whence='type -a'           # where, of a sort
alias grep="grep ${__COLORARG}"   # show differences in colour
alias egrep="egrep ${__COLORARG}" # show differences in colour
alias fgrep="fgrep ${__COLORARG}" # show differences in colour

unset __COLORARG
