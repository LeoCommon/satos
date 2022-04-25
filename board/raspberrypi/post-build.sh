#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# Mount persistent data partition
if [ -e ${TARGET_DIR}/etc/fstab ]; then
	grep -qE 'LABEL=data' ${TARGET_DIR}/etc/fstab || \
	echo "LABEL=data /data ext4 defaults,data=journal,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
fi