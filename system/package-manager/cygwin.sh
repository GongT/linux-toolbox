copy_bin cygwin/setup

export SYSTEM_PACKAGE_MANAGER="cygwin-install-note"

function cygwin-install-note {
    echo -e "\e[38;5;9mRequired to install packages: $@\e[0m"
    echo "   but there is cygwin, you must install these by \"setup\" command."
    exit 1
}

emit "export SYSTEM_PACKAGE_MANAGER='${SYSTEM_PACKAGE_MANAGER}'"
emit '
function package-manager-make-cache {
	echo "no package manager on cygwin"
    exit 1
}
function cygwin-install-note {
    echo -e "\e[38;5;9mRequired to install packages: $@\e[0m"
    echo "   but there is cygwin, you must install these by \"setup\" command."
    exit 1
}
'


