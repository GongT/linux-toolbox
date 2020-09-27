if ! command_exists git ; then
	return 0
fi

emit_file alias/git.sh
copy_bin bin/git-find-large

git config --system core.autocrlf input
git config --system core.eol lf
# git config --system 'url "file://".insteadOf' git+file://
git config --system push.default upstream
# git config --system submodule.recurse true
git config --system fetch.recurseSubmodules on-demand
git config --system pull.rebase true
