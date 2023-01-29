#!/bin/bash
set -e

RAUC_PKI_OPTIONS="--cert ${BR2_EXTERNAL_SATOS_PATH}/ota/dev-ca.pem --key ${BR2_EXTERNAL_SATOS_PATH}/ota/dev-key.pem"
RAUC_CERT_NAME="${BR2_EXTERNAL_SATOS_PATH}/ota/dev-ca.pem"
RAUC_BUNDLE_BASE_FILENAME="satos-${BOARD_NAME}-${VERSION}"

if [ "$DEPLOYMENT_MODE" == "production" ]; then
    RAUC_PKI_OPTIONS="--cert ${BR2_EXTERNAL_SATOS_PATH}/ota/prod-ca.pem --key ${BR2_EXTERNAL_SATOS_PATH}/ota/prod-key.pem" 
    RAUC_CERT_NAME="${BR2_EXTERNAL_SATOS_PATH}/ota/prod-ca.pem"
fi


function rauc_generate_root_bundle {
    ROOTFS_PATH=${BINARIES_DIR}/${RAUC_BUNDLE_BASE_FILENAME}-rootfs.raucb
    [ -e ${ROOTFS_PATH} ] && rm -rf ${ROOTFS_PATH}
    [ -e ${BINARIES_DIR}/temp-rootfs ] && rm -rf ${BINARIES_DIR}/temp-rootfs
    mkdir -p ${BINARIES_DIR}/temp-rootfs

    cat >> ${BINARIES_DIR}/temp-rootfs/manifest.raucm << EOF 
[update]
compatible=satos-${BOARD_NAME}
version=${VERSION}
[bundle]
format=verity
[image.rootfs]
filename=rootfs.ext4
EOF

    ln -L ${BINARIES_DIR}/rootfs.ext4 ${BINARIES_DIR}/temp-rootfs/

    # Generate OTA for rootfs
    ${HOST_DIR}/bin/rauc bundle ${RAUC_PKI_OPTIONS} ${BINARIES_DIR}/temp-rootfs/ ${ROOTFS_PATH}
}


function rauc_generate_boot_bundle {
    # Generate a RAUC update bundle for the boot filesystem
    BOOTFS_PATH=${BINARIES_DIR}/${RAUC_BUNDLE_BASE_FILENAME}-bootfs.raucb
    [ -e ${BOOTFS_PATH} ] && rm -rf ${BOOTFS_PATH}
    [ -e ${BINARIES_DIR}/temp-bootfs ] && rm -rf ${BINARIES_DIR}/temp-bootfs
    mkdir -p ${BINARIES_DIR}/temp-bootfs

    cat >> ${BINARIES_DIR}/temp-bootfs/manifest.raucm << EOF
[update]
compatible=satos-${BOARD_NAME}
version=${VERSION}
[bundle]
format=verity
[image.bootloader]
filename=boot.vfat
EOF

    ln -L ${BINARIES_DIR}/boot.vfat ${BINARIES_DIR}/temp-bootfs/

    # Generate rauc bundle for bootfs
    ${HOST_DIR}/bin/rauc bundle ${RAUC_PKI_OPTIONS} ${BINARIES_DIR}/temp-bootfs/ ${BOOTFS_PATH}
}

function rauc_generate_ota_bundle {
    # Generate a RAUC update bundle for the all filesystems
    FULLFS_PATH=${BINARIES_DIR}/${RAUC_BUNDLE_BASE_FILENAME}-ota.raucb
    [ -e ${FULLFS_PATH} ] && rm -rf ${FULLFS_PATH}
    [ -e ${BINARIES_DIR}/temp-fullfs ] && rm -rf ${BINARIES_DIR}/temp-fullfs
    mkdir -p ${BINARIES_DIR}/temp-fullfs

    cat >> ${BINARIES_DIR}/temp-fullfs/manifest.raucm << EOF
[update]
compatible=satos-${BOARD_NAME}
version=${VERSION}
[bundle]
format=verity
[image.bootloader]
filename=boot.vfat
[image.rootfs]
filename=rootfs.ext4
EOF

    ln -L ${BINARIES_DIR}/boot.vfat ${BINARIES_DIR}/temp-fullfs/
    ln -L ${BINARIES_DIR}/rootfs.ext4 ${BINARIES_DIR}/temp-fullfs/

    # Generate rauc bundle for the ota
    ${HOST_DIR}/bin/rauc bundle ${RAUC_PKI_OPTIONS} ${BINARIES_DIR}/temp-fullfs/ ${FULLFS_PATH}
}

function rauc_copy_keyring {
    cp "${RAUC_CERT_NAME}" "${TARGET_DIR}/etc/rauc/keyring.pem"
}