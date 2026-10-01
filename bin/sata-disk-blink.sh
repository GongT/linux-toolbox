#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit extglob nullglob globstar lastpipe shift_verbose

WHAT=${1:-}

blink() {
    local WHAT=$1
    echo "Blinking disk: ${WHAT}"
    dd "if=${WHAT}" "iseek=${RANDOM}" of=/dev/null bs=1M count=100 >/dev/null 2>&1
    sleep 1
}

if [[ "${WHAT}" ]]; then
    if [[ -e ${WHAT} ]]; then
        :
    elif [[ -e "/dev/${WHAT}" ]]; then
        WHAT="/dev/${WHAT}"
    else
        echo "Error: Device ${WHAT} does not exist." >&2
        exit 1
    fi

    while true; do
        blink "${WHAT}"
    done
else
    echo "Blinking all SATA disks..."
    while true; do
        for I in /dev/sd*; do
            if [[ ${I} =~ [0-9]$ ]]; then
                continue
            fi

            blink "${I}"
        done
    done
fi
