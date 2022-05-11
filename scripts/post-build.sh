#!/bin/bash
set -e

SCRIPT_DIR=${BR2_EXTERNAL_SATOS_PATH}/scripts
BOARD_DIR=${2}
BOARD_NAME="$(basename ${BOARD_DIR})"

. "${BR2_EXTERNAL_SATOS_PATH}/meta"
. "${BOARD_DIR}/meta"

# /data can be implemented differently but is fixed, so we can assume it exists!
# Hardlink the main NetworkManager system-connections directory to the persistent "data" folder
# Make sure device_table.txt has the proper 0600 permissions for all files in /data/system-connections set!
if [ -e ${TARGET_DIR}/etc/fstab ]; then
        echo "/data/system-connections /etc/NetworkManager/system-connections none bind 0 0" >> ${TARGET_DIR}/etc/fstab
        echo "LABEL=discosat-config /data/discosat-config ext4 defaults,nofail 0 0" >> ${TARGET_DIR}/etc/fstab
fi

. "${SCRIPT_DIR}/rauc.sh"

# Run the required RAUC tasks
rauc_copy_keyring
