CYG_SYS_BASHRC=1

# Exclude *dlls from TAB expansion
list add EXECIGNORE "*/*.dll"
export EXECIGNORE

# Uncomment to use the terminal colours set in DIR_COLORS
eval "$(dircolors -b /etc/DIR_COLORS)"
