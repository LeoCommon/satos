#!/bin/bash
set -e

# The base file name
RAUC_BUNDLE_PREFIX=satos-${BOARD_NAME}
RAUC_BUNDLE_BASE_FILENAME="${RAUC_BUNDLE_PREFIX}-${VERSION}"
RAUC_VERSION=${VERSION:-${BR2_VERSION_FULL}}

RAUC_CERT_PATH="${BR2_EXTERNAL_SATOS_PATH}/ota/dev-ca.pem"
RAUC_KEY_PATH="${BR2_EXTERNAL_SATOS_PATH}/ota/dev-key.pem"
RAUC_KEYRING_PATH="${RAUC_CERT_PATH}" # No keyring for development builds!

if [[ "${DEPLOYMENT_MODE:-}" == "production" ]]; then
	RAUC_CERT_PATH="${BR2_EXTERNAL_SATOS_PATH}/ota/prod-ca.pem"
	RAUC_KEY_PATH="${BR2_EXTERNAL_SATOS_PATH}/ota/prod-key.pem"
	RAUC_KEYRING_PATH="${BR2_EXTERNAL_SATOS_PATH}/ota/prod-keyring.pem"
fi

# Inspired by https://github.com/cdsteinkuehler/br2rauc/blob/ebe5fd8f96ef1b0ceb1c8d4c91d9730d4162f3dc/board/raspberrypi/post-image.sh#L89
# This function allows sdcard images to have proper state files
function rauc_generate_status_file_from_ota {
	OTA_BUNDLE_PATH=${BINARIES_DIR}/${RAUC_BUNDLE_BASE_FILENAME}-ota.raucb

	# Use source_date_epoch if set
	if [[ -n ${SOURCE_DATE_EPOCH:-} ]]; then
		INSTALL_TIME=$(date -d @"${SOURCE_DATE_EPOCH}" -u +"%Y-%m-%dT%H:%M:%SZ")
	else
		INSTALL_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
	fi

	# Create a staging folder
	RAUC_STAGING_FOLDER=${BINARIES_DIR}/rauc
	[ -e "${RAUC_STAGING_FOLDER}" ] && rm -rf "${RAUC_STAGING_FOLDER}"
	mkdir -p "${RAUC_STAGING_FOLDER}"

	# Run the info command on the bundle to get the required variables
	eval "$(rauc --keyring "${RAUC_KEYRING_PATH}" --output-format=shell info "${OTA_BUNDLE_PATH}")"

	# Check if the image is adaptive, and if it is set up and extract the bundle
	if compgen -A variable | grep -q RAUC_IMAGE_ADAPTIVE_; then
		echo "At least one image is adaptive, executing extra logic"
		BUNDLE_WORKDIR=${BINARIES_DIR}/temp-bundle

		# Delete directory in case it was not deleted before
		[[ -n ${BUNDLE_WORKDIR:-} ]] && rm -rf "${BUNDLE_WORKDIR}"

		# Extract the entire bundle, we need to do this for the block-hash-index files
		rauc --keyring "${RAUC_KEYRING_PATH}" --trust-environment extract "${OTA_BUNDLE_PATH}" "${BUNDLE_WORKDIR}"
	fi

	# First find out about the slots we have installed
	awk "/\[slot/" "${TARGET_DIR}"/etc/rauc/system.conf | while read -r slot_title; do
		# Split after removing the brackets around [slot.0.rootfs]
		IFS=. read -r _ slot_class slot_idx <<<"${slot_title:1:-1}"

		# Loop through everything thats in the ota bundle
		for i in $(seq 0 "${RAUC_MF_IMAGES}"); do
			current_slot_class=RAUC_IMAGE_CLASS_${i}

			# Search for a matching slot class entry
			if [[ ${!current_slot_class} != "${slot_class}" ]]; then
				continue
			fi

			# Prepare the extraction of variables
			digest=RAUC_IMAGE_DIGEST_${i}
			size=RAUC_IMAGE_SIZE_${i}

			# Add a newline between entries
			if [ "$i" -gt 0 ]; then
				echo -en "\n" >>"${RAUC_STAGING_FOLDER}"/status.db
			fi

			# Append the entry to the status file
			cat >>"${RAUC_STAGING_FOLDER}"/status.db <<EOL
${slot_title}
bundle.compatible=${RAUC_MF_COMPATIBLE}
bundle.version=${RAUC_MF_VERSION}
status=ok
sha256=${!digest}
size=${!size}
installed.timestamp=${INSTALL_TIME}
installed.count=1
EOL

			# Check if we are in adaptive mode and if it contains block-hash-index
			adaptive=RAUC_IMAGE_ADAPTIVE_${i}
			if [[ -n ${BUNDLE_WORKDIR:-} ]] && [[ ${!adaptive:-} = *"block-hash-index"* ]]; then
				# Create the target directory
				block_hash_target_dir="${RAUC_STAGING_FOLDER}/slot.${slot_class}.${slot_idx}/hash-${!digest}"
				mkdir -p "${block_hash_target_dir}"

				# Symlink the required files, they will get copied later
				image_name=RAUC_IMAGE_NAME_$i
				ln -Lf "${BUNDLE_WORKDIR}"/"${!image_name}".block-hash-index "${block_hash_target_dir}"/block-hash-index
			fi
		done
	done

	# Delete image working directory
	[[ -n ${BUNDLE_WORKDIR:-} ]] && rm -rf "${BUNDLE_WORKDIR}"

	# Bake in files to the sd-card image so first-boot script can copy them
	cd "${RAUC_STAGING_FOLDER}"
	find . -type f -exec install -m 644 -D {} "${ROOTPATH_TMP}"/provisioning/rauc/{} \;

	# Switch back to previous directory
	cd -

	# Delete staging directory
	rm -rf "${RAUC_STAGING_FOLDER}"
}

function rauc_generate_ota_bundle {
	# Generate a RAUC update bundle for the all filesystems
	FULLFS_PATH=${BINARIES_DIR}/${RAUC_BUNDLE_BASE_FILENAME}-ota.raucb
	[ -e "${FULLFS_PATH}" ] && rm -rf "${FULLFS_PATH}"
	FULLFS_STAGING_DIR="${BINARIES_DIR}"/temp-fullfs
	[ -e "${FULLFS_STAGING_DIR}" ] && rm -rf "${FULLFS_STAGING_DIR}"
	mkdir -p "${FULLFS_STAGING_DIR}"

	# Write manifest to file
	MANIFEST_FILE=${BINARIES_DIR}/temp-fullfs/manifest.raucm
	cat >"${MANIFEST_FILE}" <<EOL
[update]
compatible=satos-${BOARD_NAME}
version=${RAUC_VERSION}

[bundle]
format=verity

[image.bootloader]
filename=boot.vfat

[image.rootfs]
filename=rootfs.img
adaptive=block-hash-index
EOL

	# Check for the presence of a rootfs rauc hook
	if [ -e "${BOARD_DIR}"/rauc/hook ]; then
		echo "Adding hook to rootfs bundle section"
		cat >>"${MANIFEST_FILE}" <<EOL
hooks=pre-install;post-install

[hooks]
filename=hook
hooks=install-check
EOL
		# Symlink the hook to its target
		ln -L "${BOARD_DIR}"/rauc/hook "${FULLFS_STAGING_DIR}"/hook
	fi

	ln -L "${BINARIES_DIR}"/boot.vfat "${FULLFS_STAGING_DIR}"/
	# This has to end on .img for rauc to accept it
	ln -L "${BINARIES_DIR}"/rootfs.erofs "${FULLFS_STAGING_DIR}"/rootfs.img

	# Generate rauc bundle for the ota
	# 	For ZSTD use: --mksquashfs-args="-comp zstd -Xcompression-level 22"
	# 	For XZ use: --mksquashfs-args="-comp xz -Xdict-size 100%"
	# Tests have shown that XZ generates the smallest bundles
	rauc --cert "${RAUC_CERT_PATH}" --keyring "${RAUC_KEYRING_PATH}" --key "${RAUC_KEY_PATH}" \
		--mksquashfs-args="-comp xz -Xdict-size 100%" \
		bundle "${FULLFS_STAGING_DIR}"/ "${FULLFS_PATH}"

	# Delete staging directory
	rm -rf "${FULLFS_STAGING_DIR}"

	# Symlink latest ota for board
	ln -Lf "${FULLFS_PATH}" "${BINARIES_DIR}"/"${RAUC_BUNDLE_PREFIX}"-latest-ota.raucb
}

function rauc_copy_keyring {
	install -m 644 "${RAUC_KEYRING_PATH}" "${TARGET_DIR}"/etc/rauc/keyring.pem
}
