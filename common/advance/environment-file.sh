function environment-file() {
	local -r FILE=$1 NAME=$2 VALUE=$3

	if [[ -e "$FILE" ]]; then
		sed -i "/^export ${NAME}=/d" "$FILE"
	fi

	if [[ "$VALUE" ]]; then
		echo "export $NAME='$VALUE'" >>"$FILE"
	fi
}

function envfile-system() {
	environment-file /etc/profile.d/00-environment.sh "$1" "$2"
}
function envfile-user() {
	environment-file ~/.bash_environment.sh "$1" "$2"
}
