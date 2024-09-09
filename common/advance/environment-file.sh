function environment-file() {
	if [[ $# -gt 3 || $# -lt 2 ]] || [[ $2 == --unset && $# -eq 2 ]] || [[ $2 != --unset && $2 == -* ]]; then
		echo "Usage:
	Set value:    environment-file filePath SOME_VAR new_value
	Unset value:  environment-file filePath --unset SOME_VAR
	Show value:   environment-file filePath SOME_VAR
" >&2
		return 1
	fi

	local -r FILE="$1"
	if [[ -e $FILE ]] && ! [[ -r $FILE ]]; then
		echo "No read permission on environment file: $FILE" >&2
		return 1
	elif [[ -L $FILE ]] && ! [[ -e $FILE ]]; then
		echo "Symlink target is missing: $FILE" >&2
		return 1
	fi

	local LINE LINES=()
	local HIT=0
	if [[ $2 == "--unset" ]]; then
		# remove value
		local -r NAME="$3"
		while IFS= read -r LINE; do
			if [[ $LINE == "export $NAME="* || $LINE == "$NAME="* ]]; then
				echo "remove: $LINE" >&2
				HIT=1
				continue
			fi
			LINES+=("$LINE")
		done <"$FILE"

		if [[ $HIT -eq 0 ]]; then
			echo "no variable: $NAME" >&2
			return
		fi

		printf '%s\n' "${LINES[@]}" >"$FILE"
	elif [[ $# -eq 2 ]]; then
		# print value
		local -r NAME="$2"
		while IFS= read -r LINE; do
			if [[ $LINE == "export $NAME="* || $LINE == "$NAME="* ]]; then
				echo "$LINE"
				HIT=1
			fi
		done <"$FILE"

		if [[ $HIT -eq 0 ]]; then
			echo "no variable: $NAME" >&2
		fi
	else
		# update value
		local -r NAME="$2" VALUE="$3"
		while IFS= read -r LINE; do
			if [[ $LINE == "export $NAME="* || $LINE == "$NAME="* ]]; then
				if [[ $HIT -eq 1 ]]; then
					echo "removed: $LINE" >&2
					continue
				fi
				echo "change: $LINE" >&2
				LINE="export $NAME=$(printf %q "$VALUE")"
				HIT=1
			fi
			LINES+=("$LINE")
		done <"$FILE"

		if [[ $HIT -eq 0 ]]; then
			echo "add: $NAME" >&2
			LINES+=("export $NAME=$(printf %q "$VALUE")")
		fi

		printf '%s\n' "${LINES[@]}" >"$FILE"
	fi
}

function envfile-system() {
	if [[ $# -gt 2 ]] || [[ $1 == --unset && $# -eq 1 ]] || [[ $1 != --unset && $1 == -* ]]; then
		echo "Usage: (edit /etc/profile.d/50-environment.sh)
	Set value:    envfile-system SOME_VAR new_value
	Unset value:  envfile-system --unset SOME_VAR
	Show value:   envfile-system SOME_VAR
" >&2
		return 1
	fi
	if [[ $# -eq 0 ]]; then
		cat "/etc/profile.d/50-environment.sh"
		return
	fi
	if [[ $1 == "--unset" ]]; then
		unset "$2" || return 1
	elif [[ $# -eq 2 ]]; then
		export "$1=$2" || return 1
	fi
	environment-file /etc/profile.d/50-environment.sh "$@"
}
function envfile-user() {
	if [[ $# -gt 2 ]] || [[ $1 == --unset && $# -eq 1 ]] || [[ $1 != --unset && $1 == -* ]]; then
		echo "Usage: (edit $HOME/.bash_environment.sh)
	Set value:    envfile-user SOME_VAR new_value
	Unset value:  envfile-user --unset SOME_VAR
	Show value:   envfile-user SOME_VAR
" >&2
		return 1
	fi
	if [[ $# -eq 0 ]]; then
		cat "$HOME/.bash_environment.sh"
		return
	fi
	if [[ $1 == "--unset" ]]; then
		unset "$2" || return 1
	elif [[ $# -eq 2 ]]; then
		export "$1=$2" || return 1
	fi
	environment-file "$HOME/.bash_environment.sh" "$@"
}
