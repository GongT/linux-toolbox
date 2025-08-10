#!/bin/bash

function clean_images {
	docker images | grep -E '<none>'  | awk '{print $3}' | tee /dev/stderr | xargs --no-run-if-empty docker rmi
}
function clear_stopped_container {
	docker ps -a | tail -n +2 | grep -v Up | awk '{print $1}' | tee /dev/stderr | xargs --no-run-if-empty docker rm
}

case $1 in
clean)
	shift
	clear_stopped_container
	clean_images
;;
*)
	${DOCKER} "$@"
esac
