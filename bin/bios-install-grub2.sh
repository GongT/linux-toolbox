#!/bin/bash

set -e

if [ -z "$1" ]; then
	DISKNAME=$(mount --show-labels | grep -Po '^(/dev/.*?)\d+ on /boot ' | sed -E 's#[0-9]+ on /boot $##g')
else
	DISKNAME=$1
fi

echo "Installing grub2 to $DISKNAME"

OUTPUT=
function run() {
	OUTPUT=$("$@" 2>&1)
	if [ $? -ne 0 ]; then
		echo "$OUTPUT"
		exit 1
	fi
}

run grub2-install \
	--modules=normal \
	--modules=terminal \
	--modules=part_gpt \
	--modules=fat \
	--modules=ext2 \
	--modules=lvm \
	--modules=png \
	--modules=usb_keyboard \
	--modules=reboot \
	--modules=ls \
	--modules=loopback \
	--modules=halt \
	--modules=help \
	--modules=configfile \
	--recheck \
	--removable \
	--boot-directory=/boot \
	--efi-directory=/boot \
	--bootloader-id="Fedora Linux" \
	--locales="zh_CN" \
	--debug \
	$DISKNAME

echo "$OUTPUT"
echo "grub2-install ok."

