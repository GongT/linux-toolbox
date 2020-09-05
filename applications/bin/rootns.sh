#!/usr/bin/env bash

set -Eeuo pipefail

nsenter --preserve-credentials --no-fork "--wd=$(pwd)" --all --target "1" "$@"
