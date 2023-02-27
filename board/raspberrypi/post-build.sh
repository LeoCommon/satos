#!/bin/bash
set -u
set -e

SCRIPT_DIR=${BR2_EXTERNAL_SATOS_PATH}/scripts
BOARD_DIR=${2}
BOARD_NAME="$(basename ${BOARD_DIR})"

# Run the required RAUC tasks
. "${SCRIPT_DIR}/rauc.sh"
rauc_copy_keyring

# QEMU BUILD detected
if [ ! -z "${QEMU_BUILD:-}" ]; then
    echo "QEMU_BUILD detected, removing systemd watchdog"
    # Remove watchdog otherwise system gets stuck
    rm ${TARGET_DIR}/etc/systemd/system.conf.d/watchdog.conf
fi
