#!/bin/bash
set -e

SCRIPT_DIR=${BR2_EXTERNAL_SATOS_PATH}/scripts
BOARD_DIR=${2}
BOARD_NAME="$(basename ${BOARD_DIR})"

. "${BR2_EXTERNAL_SATOS_PATH}/meta"
. "${BOARD_DIR}/meta"

# Include the rauc script
. "${SCRIPT_DIR}/rauc.sh"

# Run the required RAUC tasks
rauc_generate_root_bundle
rauc_generate_boot_bundle