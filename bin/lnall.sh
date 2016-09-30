#!/bin/bash

#todo
exit 1

FROM="$1"
SOURCE=`ls -A ${FROM}`
TARGET="${2-.}"

for file in $SOURCE
do
	base=`basename $file`
	
	if [ -L "${TARGET}/${base}" ]; then
		unlink "${TARGET}/${base}"
	else
		echo "lnall: ${TARGET}/${base} already exist."
	fi
	
	if [ -f "${FROM}/${file}" ]; then
		CMD="ln ${FROM}/${file} ${TARGET}/${base}"
	else
		CMD="ln -s ${FROM}/${file} ${TARGET}/${base}"
	fi
	
	echo $CMD
	$CMD
done

