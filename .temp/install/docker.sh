#!/usr/bin/env bash

ensure_command curl

curl -fsSL https://get.docker.com/ \
	| sed "s#-y -q install#-y install#g" \
	| sed "s#install -y -q#install -y#g" \
	| sh
enable_service docker
