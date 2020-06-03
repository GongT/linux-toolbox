function environment-file() {
	if [[ ! "$1" ]]; then
		echo "Usage:
	Set value:    environment-file filePath SOME_VAR new_value
	Unset value:  environment-file filePath SOME_VAR
" >&2
		return 1
	fi

	local -r FILE=$1 NAME=$2 VALUE=$3

	if [[ -e "$FILE" ]]; then
		sed -i "/^export ${NAME}=/d" "$FILE"
	fi

	if [[ "$VALUE" ]]; then
		echo "export $NAME='$VALUE'" >>"$FILE"
	fi
}

function envfile-system() {
	if [[ ! "$1" ]]; then
		echo "Usage: (edit /etc/profile.d/00-environment.sh)
	Set value:    envfile-system SOME_VAR new_value
	Unset value:  envfile-system SOME_VAR
" >&2
		return 1
	fi
	environment-file /etc/profile.d/00-environment.sh "$1" "$2"

	if [[ "$2" ]]; then
		export "$1=$2"
	else
		unset "$1"
	fi
}
function envfile-user() {
	if [[ ! "$1" ]]; then
		echo "Usage: (edit $HOME/.bash_environment.sh)
	Set value:    envfile-user SOME_VAR new_value
	Unset value:  envfile-user SOME_VAR
" >&2
		return 1
	fi
	environment-file ~/.bash_environment.sh "$1" "$2"

	if [[ "$2" ]]; then
		export "$1=$2"
	else
		unset "$1"
	fi
}
