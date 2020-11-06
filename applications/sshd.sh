#!/bin/bash

if command_exists systemctl; then
	cru a "prevent-ssh-fail" "*/5 * * * * $(find_command systemctl) restart sshd.socket" "每5分钟重开ssh端口"
else
	cru d "prevent-ssh-fail"
fi
