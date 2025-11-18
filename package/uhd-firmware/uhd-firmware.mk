################################################################################
#
# uhd-firmware
#
################################################################################

UHD_FIRMWARE_VERSION = 4.7.0.0
UHD_FIRMWARE_SOURCE = uhd-images_$(UHD_FIRMWARE_VERSION).tar.xz
UHD_FIRMWARE_SITE = https://github.com/EttusResearch/uhd/releases/download/v$(UHD_FIRMWARE_VERSION)
UHD_FIRMWARE_LICENSE = Proprietary
UHD_FIRMWARE_LICENSE_FILES = LICENSE
UHD_FIRMWARE_INSTALL_TARGET = YES

# Base pattern always includes LICENSE
UHD_FIRMWARE_PATTERNS = LICENSE

# Add patterns based on enabled device support
# Keep this in sync with the p
ifeq ($(BR2_PACKAGE_UHD_B100),y)
UHD_FIRMWARE_PATTERNS += usrp_b1*
endif

ifeq ($(BR2_PACKAGE_UHD_B200),y)
UHD_FIRMWARE_PATTERNS += usrp_b2*
endif

ifeq ($(BR2_PACKAGE_UHD_USRP1),y)
UHD_FIRMWARE_PATTERNS += usrp1*
endif

ifeq ($(BR2_PACKAGE_UHD_USRP2),y)
UHD_FIRMWARE_PATTERNS += usrp2*
endif

ifeq ($(BR2_PACKAGE_UHD_E300),y)
# No idea why no E300 exist but an e310
UHD_FIRMWARE_PATTERNS += usrp_e310*
endif

ifeq ($(BR2_PACKAGE_UHD_E320),y)
UHD_FIRMWARE_PATTERNS += usrp_e320*
endif

ifeq ($(BR2_PACKAGE_UHD_N300),y)
UHD_FIRMWARE_PATTERNS += usrp_n300*
endif

ifeq ($(BR2_PACKAGE_UHD_N320),y)
UHD_FIRMWARE_PATTERNS += usrp_n320*
endif

ifeq ($(BR2_PACKAGE_UHD_X300),y)
UHD_FIRMWARE_PATTERNS += usrp_x300*
endif

define UHD_FIRMWARE_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/usr/share/uhd/images
	for pattern in $(UHD_FIRMWARE_PATTERNS); do \
		find $(@D) -maxdepth 1 -name "$$pattern" -exec $(INSTALL) -D -m 0644 {} $(TARGET_DIR)/usr/share/uhd/images/ \; ; \
	done
endef

$(eval $(generic-package))