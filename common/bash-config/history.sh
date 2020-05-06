#####
# https://gist.github.com/ckabalan/7d374ceea8c2d9dd237d763d385cf2aa
#####

# Save 5,000 lines of history in memory
HISTSIZE=10000
# Save 2,000,000 lines of history to disk (will have to grep ~/.bash_history for full listing)
HISTFILESIZE=2000000
# Append to history instead of overwrite
shopt -s histappend
# Ignore redundant or space commands
HISTCONTROL=ignoredups
# Ignore more
HISTIGNORE='ls:ll:rm -rf *:rm -f *:poweroff:reboot:systemctl reboot:systemctl poweroff:pwd:clear:history'
# Set time format
HISTTIMEFORMAT='%F %T '
# Multiple commands on one line show up as a single line
shopt -s cmdhist
# Append new history lines, clear the history list, re-read the history list, print prompt.
PROMPT_COMMAND_ACTIONS[history1]='history -a'
# PROMPT_COMMAND_ACTIONS[history2]='history -c'
# PROMPT_COMMAND_ACTIONS[history3]='history -r'
