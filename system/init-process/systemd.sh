#!/bin/sh

emit "export INIT_PROCESS=systemd"
export INIT_PROCESS=systemd

emit_alias_sudo "systemctl"
emit_alias_sudo "journalctl"
emit_alias_sudo "networkctl"
