#!/usr/bin/env bash

CONTENT=$(sed "s:__LINUX_TOOLBOX_INIT__:$TARGET:g" "$HERE/sshrc_file.sh")
append_text_file_section "$HOME/.ssh/rc" "#" "LINUX_TOOLBOX_INIT_SCRIPT" "$CONTENT"
