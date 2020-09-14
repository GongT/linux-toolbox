#!/usr/bin/env bash

set -Eeuo pipefail

podman images --format '{{.Repository}}:{{.Tag}}' \
	| grep -v "<none>" \
	| grep -v "localhost/" \
	| grep -v "example.com/" \
	| xargs --no-run-if-empty -n1 -t -IF bash -c "podman pull F ; exit 0"
