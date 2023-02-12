#!/bin/bash
set -e

SCRIPT_DIR=${BR2_EXTERNAL_SATOS_PATH}/scripts
BOARD_DIR=${2}
BOARD_NAME="$(basename ${BOARD_DIR})"

. "${BR2_EXTERNAL_SATOS_PATH}/meta"
. "${BOARD_DIR}/meta"

# QEMU BUILD detected
if [ ! -z "$QEMU_BUILD" ]; then
    echo "QEMU_BUILD detected not generating bundles"
    exit 0
fi

# Include the rauc script
. "${SCRIPT_DIR}/rauc.sh"

# Run the required RAUC tasks
rauc_generate_root_bundle
rauc_generate_boot_bundle
rauc_generate_ota_bundle