#!/bin/bash

if [[ -t 1 ]]; then
	function ls() {
		LC_ALL=zh_CN.UTF-8 command ls --color=auto "$@"
	}
else
	function ls() {
		LC_ALL=zh_CN.UTF-8 command ls "$@"
	}
fi
alias l.='ls -d .*'
alias ll='ls -lhA'
alias la='ls -hA'
alias vi='vim'

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
alias grep='grep --color'        # show differences in colour
alias egrep='egrep --color=auto' # show differences in colour
alias fgrep='fgrep --color=auto' # show differences in colour
