if command_exists killall; then
	emit "alias killall=\"$(find_command killall) --verbose --wait --ns \$\$ \""
fi
if command_exists pstree; then
	cat <<- "EOF" | sed "s#=PSTREE=#$(find_command pstree)#g" | emit_stdin
		function pstree() {
			local A=("$@")
			if [[ ${#A} -eq 0 ]]; then
				A+=(--ns-sort=pid)
			fi
			=PSTREE= \
				--unicode --hide-threads --numeric-sort --show-pids --arguments --long \
				"${A[@]}" \
				| LESSCHARSET=utf-8 less --quit-on-intr --chop-long-lines --ignore-case --RAW-CONTROL-CHARS --clear-screen
		}
	EOF
	emit "alias pstreeself=\"$(find_command pstree) --unicode --hide-threads --numeric-sort --show-pids --arguments \$\$\""
fi
if command_exists pgrep; then
	emit "alias pgrep=\"$(find_command pgrep) --ns \$\$ -f\""
fi
