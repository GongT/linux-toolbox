#!/bin/bash

alias ls='ls --color=auto'
alias l.='LC_ALL=zh_CN.UTF-8 ls -d .* --color=auto'
alias ll='LC_ALL=zh_CN.UTF-8 ls -lhA --color=auto'
alias la='LC_ALL=zh_CN.UTF-8 ls -hA --color=auto'
alias vi='vim'

# Interactive operation...
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -r'                          # raw control characters
alias whence='type -a'                        # where, of a sort
alias grep='grep --color'                     # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'              # show differences in colour
