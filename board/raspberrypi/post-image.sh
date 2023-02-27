#!/bin/bash
set -e

# BOARD_DIR is set by the BR2_ROOTFS_POST_SCRIPT_ARGS post script argument
BOARD_DIR="$2"
BOARD_NAME="$(basename ${BOARD_DIR})"
SCRIPT_DIR=${BR2_EXTERNAL_SATOS_PATH}/scripts

# Use the common genimage for all raspberry pis
GENIMAGE_CFG="${BOARD_DIR}/../genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
GENBOOTFS_CFG="${BOARD_DIR}/genimage-boot.cfg"

# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

# Generate the boot filesystem image
genimage \
	--rootpath "${ROOTPATH_TMP}" \
	--tmppath "${GENIMAGE_TMP}" \
	--inputpath "${BINARIES_DIR}" \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENBOOTFS_CFG}"

# Include rauc scripts
. "${SCRIPT_DIR}/rauc.sh"

# Run the required RAUC tasks
rauc_generate_ota_bundle
rauc_generate_status_file_from_ota

rm -rf "${GENIMAGE_TMP}"

genimage \
	--rootpath "${ROOTPATH_TMP}" \
	--tmppath "${GENIMAGE_TMP}" \
	--inputpath "${BINARIES_DIR}" \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
