#!/usr/bin/env bash

CONTENT=$(sed "s:__LINUX_TOOLBOX_INIT__:$INSTALL_TARGET_FILE:g" "$HERE/sshrc_file.sh")
append_text_file_section "$HOME/.ssh/rc" "#" "LINUX_TOOLBOX_INIT_SCRIPT" "$CONTENT"
