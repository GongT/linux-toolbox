#!/bin/bash
set -e

echo 'set global general_log = 1'
echo 'set global general_log = 1' | mysql

function cleanup {
	echo '   - stop'
	echo 'set global general_log = 0'
	echo 'set global general_log = 0' | mysql
	sudo truncate /data/log/mysqld/general.log -s 0
}
trap cleanup EXIT

echo 'watching ... '


if [ "$1" == '--long' ]; then
	sudo tail -f -n 0 /data/log/mysqld/general.log | grep -oE --line-buffered 'Query\s+.+$' | sed -u 's/Query/\x1B[38;5;9mQuery\x1B[0m/g'
elif [ "$1" == '--raw' ]; then
	sudo tail -f -n 0 /data/log/mysqld/general.log
else
	sudo tail -f -n 0 /data/log/mysqld/general.log | grep -oE --line-buffered 'Query\s+.+$' | sed -u 's/^Query/\x1B[38;5;9mQuery\x1B[0m/g' | sed -u 's/SELECT .* FROM/SELECT ... FROM/g' | sed -u 's/SET .* WHERE/SET ... WHERE/g'
fi

