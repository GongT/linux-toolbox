if ! command_exists git; then
	return 0
fi

emit_file alias/git.sh
copy_bin bin/git-find-large

if is-root; then
	LOC=--system
else
	LOC=--global
fi

git config "$LOC" core.autocrlf input
git config "$LOC" core.eol lf
# git config "$LOC" 'url "file://".insteadOf' git+file://
git config "$LOC" push.default upstream
# git config "$LOC" submodule.recurse true
git config "$LOC" fetch.recurseSubmodules on-demand
git config "$LOC" pull.rebase true

CMD=$(
	cat <<-'LINE'
		!git submodule foreach --quiet --recursive 'git reset --quiet --hard ; git clean --quiet -ffdx' && git submodule foreach 'git checkout --progress --force "$(git config --file "$toplevel/.gitmodules" --get "submodule.$name.branch")"'
	LINE
)
git config "$LOC" alias.scheckout "$CMD"

CMD=$(
	cat <<-'LINE'
		!git submodule foreach --quiet --recursive 'git reset --quiet --hard ; git clean --quiet -ffdx' && git submodule foreach 'git checkout --progress --force "$(git config --file "$toplevel/.gitmodules" --get "submodule.$name.branch")" && git pull'
	LINE
)
git config "$LOC" alias.spull "$CMD"
